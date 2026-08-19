element Element {
    shape RoundedBox
}

element Person {
    background #08427b
    color #ffffff
    shape Person
}

element "Software System" {
    background #1168bd
    color #ffffff
}

element Existing {
    background #999999
    color #ffffff
}

element Container {
    background #438dd5
    color #ffffff
}

element Web {
    shape WebBrowser
}

element Mobile {
    shape MobileDeviceLandscape
}

element Datastore {
    shape Cylinder
}

element Component {
    background #85bbf0
    color #000000
}

element Broker {
    shape Pipe
}

element Failover {
    opacity 25
}

element "Boundary:SoftwareSystem" {
    color #1168bd
}

element "Boundary:Container" {
    color #438dd5
}

relationship Relationship {
    style dotted
    color #777777
}

relationship Async {
    style dashed
}
