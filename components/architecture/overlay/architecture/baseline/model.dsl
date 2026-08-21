baselineSystem = softwareSystem "__PROJECT_NAME_DSL__ (baseline)" "The current, as-is system before the target change." {
    !adrs ./adrs
}

baselineUser = person "User" "A user of __PROJECT_NAME_DSL__."
baselineUser -> baselineSystem "Uses"
