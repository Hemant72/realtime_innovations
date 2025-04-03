part of 'employee_cubit.dart';

@immutable
sealed class EmployeeState {}

final class EmployeeInitial extends EmployeeState {}

final class EmployeeLoading extends EmployeeState {}

final class EmployeeLoaded extends EmployeeState {
  final List<Employee> currentEmployees;
  final List<Employee> previousEmployees;

  EmployeeLoaded({
    required this.currentEmployees,
    required this.previousEmployees,
  });
}

class EmployeeError extends EmployeeState {
  final String message;
  EmployeeError(this.message);
}
