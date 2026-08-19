projectSystem = softwareSystem "__PROJECT_NAME_DSL__" "TODO: Describe the system's primary responsibility." {
    !docs ./docs/src
    !adrs ./adrs
}

projectUser = person "User" "A user of __PROJECT_NAME_DSL__."
projectUser -> projectSystem "Uses"
