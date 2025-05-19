import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';


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

  final List<DateTime?> value;
  final ValueChanged<List<DateTime?>>? onValueChanged;
  final ValueChanged<DateTime>? onDisplayedMonthChanged;
  final CalendarDatePicker2WithActionButtonsConfig config;
  final Function? onCancelTapped;
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
    final size = MediaQuery.of(context).size;
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

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
        Container(
         // height: size.height * 0.065,
          width: double.infinity,
          decoration: BoxDecoration(

            border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.center,
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Expanded(
                child: TextButton(
                  onPressed: (){
                    setState(() {
                      _editCache = _values;
                      widget.onCancelTapped?.call();
                      if ((widget.config.openedFromDialog ?? false) &&
                          (widget.config.closeDialogOnCancelTapped ?? true)) {
                        Navigator.pop(context);
                      }
                    });
                  },
                  child: Text(
                    'Cancel'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(color: Colors.grey, width: 1, height: 28),
              Expanded(
                child: TextButton(
                  onPressed: () {

                    setState(() {
                      _values = _editCache;
                      widget.onValueChanged?.call(_values);
                      widget.onOkTapped?.call();

                      // Safe handling of date filter application
                      if ((widget.config.openedFromDialog ?? false) &&
                          (widget.config.closeDialogOnOkTapped ?? true)) {

                        Navigator.pop(context, _values);
                        if (_values.length >= 2 &&
                            _values[0] != null &&
                            _values[1] != null) {

                        }
                        // Only add the event if both dates are not null


                      }
                    });
                  },
                  child: Text(
                    'Apply'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


}
