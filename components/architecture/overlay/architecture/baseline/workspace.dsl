workspace extends ../base/workspace.dsl {
    name "__PROJECT_NAME_DSL__ - baseline architecture"
    model {
        archetypes {
            !include archetypes.dsl
        }

        !include model.dsl
    }

    views {
        !include views.dsl
    }
}
