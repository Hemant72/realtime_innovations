import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtime_innovations/cubit/employee_cubit.dart';
import 'package:realtime_innovations/model/employe_model.dart';
import 'package:realtime_innovations/screens/add_employee_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: BlocBuilder<EmployeeCubit, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EmployeeLoaded) {
            final currentEmployees = state.currentEmployees;
            final previousEmployees = state.previousEmployees;

            if (currentEmployees.isEmpty && previousEmployees.isEmpty) {
              return _buildEmptyState();
            }

            return _buildEmployeeList(
              context,
              currentEmployees,
              previousEmployees,
            );
          } else if (state is EmployeeError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No employee records found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(
    BuildContext context,
    List<Employee> currentEmployees,
    List<Employee> previousEmployees,
  ) {
    return ListView(
      children: [
        if (currentEmployees.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Current employees',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...currentEmployees.map(
            (employee) => _buildEmployeeItem(context, employee),
          ),
        ],
        if (previousEmployees.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Previous employees',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...previousEmployees.map(
            (employee) => _buildEmployeeItem(context, employee),
          ),
        ],
      ],
    );
  }

  Widget _buildEmployeeItem(BuildContext context, Employee employee) {
    return Dismissible(
      key: Key(employee.id.toString()),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<EmployeeCubit>().deleteEmployee(employee.id!);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${employee.name} deleted')));
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEmployeeScreen(employee: employee),
            ),
          );
        },
        child: ListTile(
          shape: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            top: BorderSide(color: Colors.grey.shade300),
          ),
          title: Text(
            employee.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.role,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                'From ${_formatDate(employee.startDate)}${employee.endDate != null ? ' - ${_formatDate(employee.endDate!)}' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
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
}
