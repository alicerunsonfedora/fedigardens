# ``SeedUI/RecursiveNavigationStack``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

### Usage over NavigationStack

This is typically used to create a navigation stack in which its contents recursively define itself and its navigation
destinations. For example, if a data type contains a property that is of the same type, you may want to create a view
that allows you to recursively go through that type:

```swift
struct Employee: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var department: Department
    var supervisors: [Employee]? 
}

struct EmployeeNavigationStack: View {
    var employee: Employee

    var body: some View {
        List {
            ...
            if let supervisors = employee.supervisors {
                Section {
                    ForEach(supervisors) { supervisor in
                        ...
                    }
                }
            }
        }
        .navigationDestination(of: Employee.self) { supervisor in
            EmployeeNavigationStack(employee: supervisor)
        }
    }
}
```

However, this does cause an issue since now the destination definition for `Employee` is being done recursively, which
`NavigationStack` does not accept. This view can utilize ``RecursiveNavigationStack`` instead to allow a recursive
definition, only defining the destination at the root level:

```swift
struct Employee: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var department: Department
    var supervisors: [Employee]? 
}

struct EmployeeNavigationStack: View {
    var employee: Employee
    var level: RecursiveNavigationStackLevel = .parent

    var body: some View {
        RecursiveNavigationStack(level: level) {
            List {
                ...
                if let supervisors = employee.supervisors {
                    Section {
                        ForEach(supervisors) { supervisor in
                            ...
                        }
                    }
                }
            }
        }
        .recursiveDestination(of: Employee.self) { supervisor in
            EmployeeNavigationStack(employee: supervisor, level: .child)
        }
    }
}
```

This allows the content to be recursively defined without overriding any destination definitions or nesting navigation
stacks with the same definition. To handle the desination definition, ``recursiveDestination(of:destination:)`` is used
instead of ``navigationDestination(for:destination:)``.

> Important: In most cases, you do not need to use a recursive navigation stack in your own views. Use this only if the
> view will recursively call itself, and that view will utilize a navigation stack with a prefedined set of
> destinations.
