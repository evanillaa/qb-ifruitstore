local Translations = {
    error = {
        canceled = 'Annulé..',
        minimum_police = 'Minimum de %{value} policiers requis',
        missing_lockpick = 'Il vous manque un Outil de Crochetage Avancé',
        active_security = 'La sécurité est toujours active..'
    },
    success = {},
    info = {
        glove_ripped = 'Vous avez déchiré vos gants..',
        grab_item = 'Déconnecter l\'objet',
        robbery_attempt = 'Tentative de cambriolage du magasin iFruit',
        robbery_attempt2 = 'Des gens essaie de voler des objets du magasin iFruit!'
    },
    general = {
        grab_item = '~g~E~w~ - Prendre l\'objet'
    }
}

Lang = Locale:new({phrases = Translations}) 
