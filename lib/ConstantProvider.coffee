fuzzaldrin = require 'fuzzaldrin'

AbstractProvider = require "./AbstractProvider"

module.exports =

##*
# Provides autocompletion for internal PHP constants.
##
class ConstantProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    fetchSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
        # These can appear pretty much everywhere, but not in variable names or as class members. We just use the regex
        # here to validate, but not to filter out the correct bits, as autocomplete-plus already seems to do this
        # correctly.
        @regex = /(?:^|[^\$:>\w])([A-Z_]+)/g

        tmpPrefix = @getPrefix(editor, bufferPosition)
        return unless tmpPrefix.length

        constants = @service.getGlobalConstants()

        return unless constants

        suggestions = @findSuggestionsForPrefix(constants, prefix.trim())
        return unless suggestions.length
        return suggestions

    ###*
     * Returns suggestions available matching the given prefix
     *
     * @param {array}  constants
     * @param {string} prefix
     *
     * @return {array}
    ###
    findSuggestionsForPrefix: (constants, prefix) ->
        flatList = (obj for name,obj of constants)

        matches = fuzzaldrin.filter(flatList, prefix, key: 'name')

        suggestions = []

        for match in matches
            suggestions.push
                text: match.name,
                type: 'constant',
                description: 'Built-in PHP constant.'

        return suggestions
