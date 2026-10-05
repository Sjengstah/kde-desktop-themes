import QtQuick

// Cockpit readouts for the wallpaper, all worked out locally from the date (nothing is
// fetched): today's destination, a May the 4th countdown and galactic standard time.
// The bar next to the badge is the hyperdrive charge: how much of the day has passed.
QtObject {
    id: d

    property bool enabled: true
    property bool loaded: true
    property real progress: -1
    property string progressLabel: ""

    readonly property var planets: [
        "TATOOINE · OUTER RIM", "HOTH · ANOIAT SECTOR", "DAGOBAH · SLUIS SECTOR",
        "ENDOR · MODDELL SECTOR", "NABOO · CHOMMELL SECTOR", "CORUSCANT · CORE WORLDS",
        "BESPIN · ANOAT SECTOR", "KASHYYYK · MYTARANOR", "MUSTAFAR · ATRAVIS SECTOR",
        "JAKKU · WESTERN REACHES", "SCARIF · ABRION SECTOR", "LOTHAL · OUTER RIM",
        "KAMINO · WILD SPACE", "GEONOSIS · ARKANIS SECTOR", "MANDALORE · OUTER RIM",
        "YAVIN 4 · GORDIAN REACH", "ALDERAAN · CORE WORLDS", "JEDHA · MID RIM"
    ]

    function dayOfYear(now) {
        return Math.floor((now - new Date(now.getFullYear(), 0, 0)) / 864e5)
    }

    function sectors(now) {
        const doy = dayOfYear(now)
        const dest = planets[(now.getFullYear() * 7 + doy) % planets.length]

        let may4 = new Date(now.getFullYear(), 4, 4)
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        if (today > may4)
            may4 = new Date(now.getFullYear() + 1, 4, 4)
        const days = Math.round((may4 - today) / 864e5)

        return [
            { title: "NAV · TODAY'S DESTINATION", value: dest },
            days === 0 ? { title: "MAY THE 4TH", value: "MAY THE FORCE BE WITH YOU", live: true }
                       : { title: "MAY THE 4TH", value: "IN " + days + (days === 1 ? " DAY" : " DAYS") },
            { title: "GALACTIC STANDARD TIME",
              value: (now.getFullYear() - 1977) + " ABY · DAY " + ("00" + doy).slice(-3) + " · " + Qt.formatTime(now, "HH:mm") }
        ]
    }

    property Timer timer: Timer {
        interval: 60000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            const n = new Date()
            d.progress = (n.getHours() * 60 + n.getMinutes()) / 1440
            d.progressLabel = "HYPERDRIVE " + Math.round(d.progress * 100) + "%"
        }
    }
}
