import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Add this import
import 'package:flutter_bloc/flutter_bloc.dart'; // Add this import
import 'package:Eswatini/bussiness_logic/transaction/transaction_bloc.dart';
import 'package:Eswatini/bussiness_logic/transaction/transaction_event.dart';// Replace with your actual path

/// Display CalendarDatePicker with action buttons
class CalendarDatePicker2WithActionButtons extends StatefulWidget {
  CalendarDatePicker2WithActionButtons({
    required this.value,
    required this.config,
    this.onValueChanged,
    this.onDisplayedMonthChanged,
    this.onCancelTapped,
    this.onOkTapped,
    Key? key,
  }) : super(key: key) {
    if (config.calendarViewMode == CalendarDatePicker2Mode.scroll) {
      assert(
      config.scrollViewConstraints?.maxHeight != null,
      'scrollViewConstraint with maxHeight must be provided when used with CalendarDatePicker2WithActionButtons under scroll mode',
      );
    }
  }

  /// The selected [DateTime]s that the picker should display.
  final List<DateTime?> value;

  /// Called when the user taps 'OK' button
  final ValueChanged<List<DateTime?>>? onValueChanged;

  /// Called when the user navigates to a new month/year in the picker under non-scroll mode
  final ValueChanged<DateTime>? onDisplayedMonthChanged;

  /// The calendar configurations including action buttons
  final CalendarDatePicker2WithActionButtonsConfig config;

  /// The callback when cancel button is tapped
  final Function? onCancelTapped;

  /// The callback when ok button is tapped
  final Function? onOkTapped;

  @override
  State<CalendarDatePicker2WithActionButtons> createState() =>
      _CalendarDatePicker2WithActionButtonsState();
}

class _CalendarDatePicker2WithActionButtonsState
    extends State<CalendarDatePicker2WithActionButtons> {
  List<DateTime?> _values = [];
  List<DateTime?> _editCache = [];

  @override
  void initState() {
    _values = widget.value;
    _editCache = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(
      covariant CalendarDatePicker2WithActionButtons oldWidget) {
    var isValueSame = oldWidget.value.length == widget.value.length;

    if (isValueSame) {
      for (var i = 0; i < oldWidget.value.length; i++) {
        var isSame = (oldWidget.value[i] == null && widget.value[i] == null) ||
            DateUtils.isSameDay(oldWidget.value[i], widget.value[i]);
        if (!isSame) {
          isValueSame = false;
          break;
        }
      }
    }

    if (!isValueSame) {
      _values = widget.value;
      _editCache = widget.value;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final MaterialLocalizations localizations =
    MaterialLocalizations.of(context);
    double itemWidth = ((width / 3) - ((width * 0.06) / 3)).clamp(320, 400);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MediaQuery.removePadding(
          context: context,
          child: CalendarDatePicker2(
            value: [..._editCache],
            config: widget.config,
            onValueChanged: (values) => _editCache = values,
            onDisplayedMonthChanged: widget.onDisplayedMonthChanged,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCancelButton(Theme.of(context).colorScheme, localizations),
              const SizedBox(width: 10),
              _buildOkButton(Theme.of(context).colorScheme, localizations),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(ColorScheme colorScheme, MaterialLocalizations localizations) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Expanded(
      flex: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () {
          setState(() {
            _editCache = _values;
            widget.onCancelTapped?.call();
            if ((widget.config.openedFromDialog ?? false) &&
                (widget.config.closeDialogOnCancelTapped ?? true)) {
              Navigator.pop(context);
            }
          });
        },
        child: Container(
          width: double.infinity,
          height: height * 0.085,
          padding: widget.config.buttonPadding ??
              const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF57921),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(width * 0.04),
              bottomRight: Radius.circular(width * 0.04),
              bottomLeft: Radius.circular(width * 0.04),
            ),
          ),
          child: Center(
            child: widget.config.cancelButton ??
                Icon(
                  Icons.close,
                  color: Colors.white,
                  size: width * 0.08,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildOkButton(ColorScheme colorScheme, MaterialLocalizations localizations) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Expanded(
      flex: 4,
      child: SizedBox(
        height: height * 0.085,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(width * 0.04),
                bottomRight: Radius.circular(width * 0.04),
                bottomLeft: Radius.circular(width * 0.04),
              ),
            ),
          ),
          onPressed: () {
            setState(() {
              _values = _editCache;
              widget.onValueChanged?.call(_values);
              widget.onOkTapped?.call();

              // Safe handling of date filter application
              if ((widget.config.openedFromDialog ?? false) &&
                  (widget.config.closeDialogOnOkTapped ?? true)) {
                Navigator.pop(context, _values);

                // Only add the event if both dates are not null
                if (_values.length >= 2 && _values[0] != null && _values[1] != null) {
                  try {
                    context.read<TransactionBloc>().add(
                        DateFilterTransaction(
                            endDate: _values[1]!,
                            startDate: _values[0]!
                        )
                    );
                  } catch (e) {
                    print('Error applying date filter: $e');
                    // Optionally show a snackbar or other feedback
                  }
                }
              }
            });
          },
          child: Text(
            'Apply',
            style: TextStyle(fontFamily: 'Roboto', fontSize: width * 0.05),
          ),
        ),
      ),
    );
  }
}
