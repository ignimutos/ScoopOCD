## Personal Use

# Why

most of scoop bucket app do not follow [portable rule](https://portableapps.com/about/what_is_a_portable_app)

# Rule

1. directly place software data under scoop persist folder.
2. if can not keep rule#1, create junction instead.

    2.1. unlink junction when you uninstall app.

3. disable autoupdate if app exist relative setting, just use scoop to manage app.

# Warn

1.  scoop can only get bucket name by following:

        1.1. during install: `([regex]::Match(\"$PSItem\", '(._)/._')).Groups[1].Value`
        1.2. during uninstall: `([regex]::Match(\"$install\", 'bucket=(\\w\*)')).Groups[1].Value`

    by safty and convenience reason, just name this bucket 'ocd'.
