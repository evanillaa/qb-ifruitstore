local Translations = {
    error = {
        canceled = 'Canceled..',
        minimum_police = 'Minimum of %{value} police needed',
        missing_lockpick = 'You are missing an advanced lockpick',
        active_security = 'Security is still active..'
    },
    success = {},
    info = {
        glove_ripped = 'You ripped your glove..',
        grab_item = 'Disconnect Item',
        robbery_attempt = 'iFruit Store robbery attempt',
        robbery_attempt2 = 'People are trying to steal items at the iFruit Store!'
    },
    general = {
        grab_item = '~g~E~w~ - Grab item'
    }
}

Lang = Locale:new({phrases = Translations})