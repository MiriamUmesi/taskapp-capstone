output "budget_name" {
  description = "Name of the budget created"
  value       = aws_budgets_budget.monthly.name
}
