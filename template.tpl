___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Pulse Analytics",
  "brand": {
    "id": "github.com_ciphera-net",
    "displayName": "Ciphera",
    "thumbnail": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAIAAABt+uBvAAADlklEQVR4nOzcWUhUURzH8d+Z1EZS2y2iYGyhqKApWyhshRaKFnwoClpeglaihwoqqN6iXnqsoL2o7KEFgqCifaWiBQkUhKxEs9x1UtN/d/SlKP2P4/2fmSv/D4Kid16+nHvPueeOk9C0pidU23xQ7dJADA3E0EAMDcTQQAwNxNBADA3E0EAMDcTQQAwNxNBADA3E0ECMBLhu7Bwzbi46jwj1dQhVI1RJpYXIe4aGEKxzP5AZNtHM2whXmdZvuffpwRl6cRUWeeoUGzPLbDrl23Ud6QHY4sFr0OiZvsNvzcJtsMKrF2mz4oBv61kk+iHMy7PYxCW+vbekG3l8mg8EfZtPQpL310HjF5rsPRDTFRaKZukO9A9ARhdZSZvs3ZAhEYhgnZm2HINGQoBAoJoyxEK4kQD3A1FRPmLBBBdAgMAIcu4qa8ph35AxSO0HtwkEamqkS3sREwOHwW0isxg9ukB3jsM+b4ygFnRuJx1dj/paWGQ8FMhBz64075pE907BmpTecJvAjuKfyovo9Ha6vM9kLkLGBDNgKBK7My/pOzj6ZXGoCm4TDtQqVEWPL+LxRX4FGQia2evMrHWITq37s6eVQBEKzjejstAJVNNVA/m6mayVLtwrlBTAbXEQyJ9iZqxGn0HopIpifC+E22IdKK2/c9FBcho6jV5eg4CYBho4PHxmJST9/VuDqDirUwiIXaChmWbysv/9IZrdEnp4HoUfICBGgZx90pFT4ZaGOsrZBxnWAyUkmaxV7d5VdvgUaz62AdU/IMNuoB69zMy1SHPzjomuHcSrGxBjMVB6IDx2kpKZwzoygOjpZbp6EJJsBcoYb6ZkR3RkxNdounmEcvZDmJVAmYvNiMmRHhzZCArfA1vZJxAOlOg301chPaMDL+FGEN09QdcPobIEVkgGSukTXiX36OAeTVsjqOA1vblJT3JQ9gUWGal/yXQmrAVb+N2ff1BFsUlObfmJUFfp7P9TVSk+vZObyNsnNoL8qVHUCSvKo/e3ETf0TZwMDcTQQAwNxNBADA3E0EAMDcTQQAwNxNBADA3E0EAMDcTQQAwNxNBADA3E0EAMDcTQQAwNxNBADLHnYo0/EZ1fDYgnYiPIeRzqfEXh60fEEyP4acCJfgSCzhP6SI9vDOFzLiq/IZ5IvnnBOcvyn8Pj9CLN0EAMDcTQQAwNxNBADA3E0EAMDcTQQAwNxNBADA3E0EAMDcTQQIzfAAAA//9JrtcXAAAABklEQVQDAMCyzc9zetk0AAAAAElFTkSuQmCC"
  },
  "description": "Install Pulse Analytics, privacy-first web analytics from Ciphera. No cookies, no IP addresses stored, under 3 KB.",
  "categories": [
    "ANALYTICS"
  ],
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "domain",
    "displayName": "Domain",
    "simpleValueType": true,
    "help": "The domain this site is registered under in Pulse Analytics, for example example.com. Leave blank to use the page's own hostname \u2014 correct for a container that serves one site. Set it explicitly when one container serves several domains, or when the registered domain differs from the hostname."
  },
  {
    "type": "CHECKBOX",
    "name": "companion",
    "checkboxText": "Also track clicks, copies and form submits",
    "simpleValueType": true,
    "defaultValue": false
  },
  {
    "type": "GROUP",
    "name": "advanced",
    "displayName": "Advanced",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "TEXT",
        "name": "api",
        "displayName": "API origin",
        "simpleValueType": true,
        "help": "Only if you proxy Pulse Analytics through your own domain. A bare origin such as https://example.com \u2014 the script appends its own path. Leave blank otherwise.",
        "valueValidators": [
          {
            "type": "REGEX",
            "args": [
              "^$|^https?://[^/?#]+$"
            ],
            "errorMessage": "Enter a bare origin such as https://example.com, with no path."
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Pulse Analytics — privacy-first web analytics from Ciphera.
//
// Why this template configures through `window.pulseConfig` rather than the
// `data-domain` attribute the Pulse docs show: the sandboxed `injectScript(url,
// onSuccess, onFailure, cacheToken)` takes a URL and callbacks and has NO
// parameter for HTML attributes. There is no way to ask GTM for
// `<script defer data-domain="..." src="...">`. The Pulse tracker reads its
// configuration from `document.currentScript` first and falls back to
// `window.pulseConfig`, which is the path a tag manager has to use — and which
// the tracker carries deliberately for exactly this case.

const injectScript = require('injectScript');
const setInWindow = require('setInWindow');
const copyFromWindow = require('copyFromWindow');
const log = require('logToConsole');

const SCRIPT_URL = 'https://js.ciphera.net/script.js';
const COMPANION_URL = 'https://js.ciphera.net/script.interactions.js';

// Merge rather than replace: a site may already have set pulseConfig by hand,
// and clobbering it would silently drop settings this template does not model.
const existing = copyFromWindow('pulseConfig');
const config = existing ? existing : {};

if (data.domain) {
  config.domain = data.domain;
}
if (data.api) {
  config.api = data.api;
}

setInWindow('pulseConfig', config, true);

const onFailure = function () {
  log('Pulse Analytics: could not load ' + SCRIPT_URL);
  data.gtmOnFailure();
};

if (data.companion) {
  injectScript(
    SCRIPT_URL,
    function () {
      // The companion reads window.pulse per event rather than at load, so it
      // degrades safely on its own — but loading it after the core keeps an
      // early click from being dropped.
      injectScript(COMPANION_URL, data.gtmOnSuccess, onFailure, 'pulseAnalyticsCompanion');
    },
    onFailure,
    'pulseAnalytics'
  );
} else {
  injectScript(SCRIPT_URL, data.gtmOnSuccess, onFailure, 'pulseAnalytics');
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://js.ciphera.net/*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "pulseConfig"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Pulse Analytics by Ciphera BV. Source and docs: https://github.com/ciphera-net/pulse-gtm
