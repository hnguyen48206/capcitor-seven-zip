var capacitorSevenzip = (function (exports, core) {
    'use strict';

    const Sevenzip = core.registerPlugin('Sevenzip', {
        web: () => Promise.resolve().then(function () { return web; }).then((m) => new m.SevenzipWeb()),
    });

    class SevenzipWeb extends core.WebPlugin {
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        async clearProgressWatch(_options) {
            throw new Error('Method not implemented.');
        }
        async getDefaultPath() {
            throw new Error('Method not implemented.');
        }
        async unzip(
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        _options, 
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        _callback) {
            return ``;
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        SevenzipWeb: SevenzipWeb
    });

    exports.Sevenzip = Sevenzip;

    Object.defineProperty(exports, '__esModule', { value: true });

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
