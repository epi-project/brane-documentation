(() => {
    var e = (() => {
        "use strict";
        return (e) => {
            return {
                name: "BraneScript",
                aliases: [ "bs", "bscript", "branescript" ],
                keywords: {
                    keyword: 'break class continue else for func if import let new on parallel return while',
                    literal: 'true false null',
                    built_in: 'Data IntermediateResult',
                },
                contains: [
                    e.QUOTE_STRING_MODE,
                    e.NUMBER_MODE,
                    e.C_LINE_COMMENT_MODE,
                    e.C_BLOCK_COMMENT_MODE,
                ]
            };
        };
    })();
    hljs.registerLanguage("bscript", e);
})();
