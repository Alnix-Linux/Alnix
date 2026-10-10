// Pin Alnix Store to the task manager in place of Discover

const taskManagers = [
    "org.kde.plasma.icontasks",
    "org.kde.plasma.taskmanager",
];

const discover = "applications:org.kde.discover.desktop";
const store = "applications:io.qzz.oliik.alnixstore.desktop";

// Plasma's built-in launchers, used when none have been saved yet.
const defaultLaunchers = [
    "applications:systemsettings.desktop",
    discover,
    "preferred://filemanager",
    "preferred://browser",
];

const containments = desktops().concat(panels());
for (var i in containments) {
    const widgets = containments[i].widgets();
    for (var j in widgets) {
        const widget = widgets[j];
        if (taskManagers.indexOf(widget.type) === -1) {
            continue;
        }
        widget.currentConfigGroup = new Array("General");

        var launchers = widget.readConfig("launchers", "");
        if (typeof launchers === "string") {
            launchers = launchers.split(",");
        }
        launchers = launchers.filter(function (launcher) { return launcher !== ""; });
        if (launchers.length === 0) {
            launchers = defaultLaunchers.slice();
        }

        const hasStore = launchers.indexOf(store) !== -1;
        const index = launchers.indexOf(discover);
        if (index !== -1) {
            if (hasStore) {
                launchers.splice(index, 1);
            } else {
                launchers[index] = store;
            }
        } else if (!hasStore) {
            launchers.push(store);
        }
        widget.writeConfig("launchers", launchers.join(","));
    }
}
