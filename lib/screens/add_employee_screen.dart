import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtime_innovations/cubit/employee_cubit.dart';
import 'package:realtime_innovations/model/employe_model.dart';
import 'package:realtime_innovations/screens/date_picker_screen.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Employee? employee;
  const AddEmployeeScreen({super.key, this.employee});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _selectedRole = '';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _roles = [
    'Product Designer',
    'Flutter Developer',
    'QA Tester',
    'Product Owner',
    'Full-stack Developer',
    'Senior Software Developer',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _selectedRole = widget.employee!.role;
      _startDate = widget.employee!.startDate;
      _endDate = widget.employee!.endDate;
    } else {
      _startDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.employee == null ? 'Add Employee Details' : 'Employee Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Employee name',
                  prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black, width: 0.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter employee name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildRoleDropdown(),
              const SizedBox(height: 16),
              _buildDateFields(),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: _showRoleSelector,
        child: InputDecorator(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.work_outline, color: Colors.blue),
            labelText: '',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedRole.isEmpty ? 'Select role' : _selectedRole,
                style: TextStyle(color: Colors.black),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: ListView.separated(
            itemCount: _roles.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_roles[index], textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    _selectedRole = _roles[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDateFields() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(isStartDate: true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _startDate == null ? 'Today' : _formatDate(_startDate!),
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Icon(Icons.arrow_forward, color: Colors.blue),
        ),
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(isStartDate: false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _endDate == null ? 'No date' : _formatDate(_endDate!),
                    style: TextStyle(
                      color: _endDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final DateTime? pickedDate = await DateDialog.show(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? null : _startDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  void _saveEmployee() {
    if (_formKey.currentState!.validate() && _selectedRole.isNotEmpty) {
      final employee = Employee(
        id: widget.employee?.id,
        name: _nameController.text,
        role: _selectedRole,
        startDate: _startDate!,
        endDate: _endDate,
      );

      if (widget.employee == null) {
        context.read<EmployeeCubit>().addEmployee(employee);
      } else {
        context.read<EmployeeCubit>().updateEmployee(employee);
      }

      Navigator.pop(context);
    } else if (_selectedRole.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a role')));
    }
  }
}
