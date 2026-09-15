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
  "description": "Install Pulse Analytics, privacy-first web analytics from Ciphera. No cookies, no personal data, under 3 KB.",
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
    "help": "The domain this site is registered under in Pulse Analytics, for example <strong>example.com</strong>. Leave blank to use the page's own hostname \u2014 correct for a container that serves one site. Set it explicitly when one container serves several domains, or when the registered domain differs from the hostname."
  },
  {
    "type": "CHECKBOX",
    "name": "companion",
    "checkboxText": "Also track clicks, copies and form submits",
    "simpleValueType": true,
    "help": "Loads a second, separate script. The core script's size is a published claim, so nothing is folded into it."
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
        "help": "Only if you proxy Pulse Analytics through your own domain. A bare origin such as <strong>https://example.com</strong> \u2014 the script appends its own path. Leave blank otherwise.",
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

scenarios:
- name: Injects the core script and nothing else by default
  code: |-
    const mockData = { domain: 'example.com' };

    mock('injectScript', (url, onSuccess) => {
      assertThat(url).isEqualTo('https://js.ciphera.net/script.js');
      onSuccess();
    });

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();
- name: Sets the domain on window.pulseConfig, because attributes are not available
  code: |-
    const mockData = { domain: 'example.com' };
    let written;

    mock('copyFromWindow', () => undefined);
    mock('setInWindow', (key, value) => { if (key === 'pulseConfig') written = value; });
    mock('injectScript', (url, onSuccess) => onSuccess());

    runCode(mockData);

    assertThat(written.domain).isEqualTo('example.com');
- name: Leaves the domain unset when blank, so the tracker auto-detects the hostname
  code: |-
    const mockData = {};
    let written;

    mock('copyFromWindow', () => undefined);
    mock('setInWindow', (key, value) => { if (key === 'pulseConfig') written = value; });
    mock('injectScript', (url, onSuccess) => onSuccess());

    runCode(mockData);

    assertThat(written.domain).isEqualTo(undefined);
- name: Keeps a pulseConfig the site already set
  code: |-
    const mockData = { domain: 'example.com' };
    let written;

    mock('copyFromWindow', () => ({ hashMode: true }));
    mock('setInWindow', (key, value) => { if (key === 'pulseConfig') written = value; });
    mock('injectScript', (url, onSuccess) => onSuccess());

    runCode(mockData);

    assertThat(written.hashMode).isEqualTo(true);
    assertThat(written.domain).isEqualTo('example.com');
- name: Loads the companion second when asked, and only then
  code: |-
    const mockData = { domain: 'example.com', companion: true };
    const loaded = [];

    mock('injectScript', (url, onSuccess) => { loaded.push(url); onSuccess(); });

    runCode(mockData);

    assertThat(loaded).isEqualTo([
      'https://js.ciphera.net/script.js',
      'https://js.ciphera.net/script.interactions.js'
    ]);
- name: Fails the tag when the script cannot load, rather than reporting success
  code: |-
    const mockData = { domain: 'example.com' };

    mock('injectScript', (url, onSuccess, onFailure) => onFailure());

    runCode(mockData);

    assertApi('gtmOnFailure').wasCalled();
    assertApi('gtmOnSuccess').wasNotCalled();


___NOTES___

Pulse Analytics is privacy-first web analytics from Ciphera BV, a company in
Belgium. It sets no cookies, stores no personal data, and the script this tag
loads is under 3 KB. Visitors whose browser sends Do Not Track or Global Privacy
Control are not counted at all.

Source: https://github.com/ciphera-net/pulse-gtm
Docs:   https://docs.ciphera.net/pulse/framework-guides

This template is not affiliated with, endorsed by, or sponsored by Google.
Google Tag Manager is a trademark of Google LLC.
