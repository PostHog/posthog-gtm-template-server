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
  "displayName": "PostHog",
  "categories": [
    "ANALYTICS",
    "CONVERSIONS"
  ],
  "brand": {
    "id": "github.com_PostHog",
    "displayName": "PostHog"
  },
  "description": "Forward server container events to the PostHog capture API. Maps the incoming event to a PostHog event name, distinct ID and properties.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "projectToken",
    "displayName": "Project API key",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "Found in <a href=\"https://us.posthog.com/settings/project\">your project settings</a>. It starts with <code>phc_</code>."
  },
  {
    "type": "SELECT",
    "name": "region",
    "displayName": "Region",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "us",
        "displayValue": "US Cloud (us.i.posthog.com)"
      },
      {
        "value": "eu",
        "displayValue": "EU Cloud (eu.i.posthog.com)"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "us",
    "help": "Self-hosted instances are not supported, because Google Tag Manager requires request URLs to be declared in the template."
  },
  {
    "type": "GROUP",
    "name": "eventGroup",
    "displayName": "Event",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "eventName",
        "displayName": "Event name",
        "simpleValueType": true,
        "help": "Leave empty to use the incoming event name from the client."
      },
      {
        "type": "TEXT",
        "name": "distinctId",
        "displayName": "Distinct ID",
        "simpleValueType": true,
        "help": "Leave empty to use <code>user_id</code>, falling back to <code>client_id</code> from the incoming event."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "propertiesGroup",
    "displayName": "Properties",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "includeAllEventData",
        "checkboxText": "Include all incoming event data as properties",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Copies every key from the incoming event onto the PostHog event. Turn this off to send only the properties you list below."
      },
      {
        "type": "SIMPLE_TABLE",
        "name": "extraProperties",
        "displayName": "Additional properties",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Property",
            "name": "key",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT"
          }
        ],
        "newRowButtonText": "Add property",
        "help": "These are applied after the incoming event data, so they win on a name clash."
      },
      {
        "type": "CHECKBOX",
        "name": "processPersonProfile",
        "checkboxText": "Create or update a person profile for this event",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Turn this off for anonymous events. See <a href=\"https://posthog.com/docs/data/anonymous-vs-identified-events\">anonymous vs identified events</a>."
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "enableLogging",
    "checkboxText": "Log requests and responses",
    "simpleValueType": true,
    "defaultValue": false,
    "help": "Writes to Google Cloud Logging. Leave off in production."
  }
]


___SANDBOXED_JS_FOR_SERVER___

const JSON = require('JSON');
const getAllEventData = require('getAllEventData');
const getEventData = require('getEventData');
const logToConsole = require('logToConsole');
const makeString = require('makeString');
const makeTableMap = require('makeTableMap');
const sendHttpRequest = require('sendHttpRequest');

const API_HOSTS = {
  us: 'https://us.i.posthog.com',
  eu: 'https://eu.i.posthog.com'
};

const log = function(message) {
  if (data.enableLogging) {
    logToConsole('[PostHog] ' + message);
  }
};

const eventName = data.eventName || getEventData('event_name');
if (!eventName) {
  log('No event name on the tag or the incoming event.');
  data.gtmOnFailure();
  return;
}

const distinctId = data.distinctId || getEventData('user_id') || getEventData('client_id');
if (!distinctId) {
  log('No distinct ID. Set one on the tag, or send user_id or client_id from the client.');
  data.gtmOnFailure();
  return;
}

const properties = data.includeAllEventData ? getAllEventData() : {};

const extras = makeTableMap(data.extraProperties || [], 'key', 'value') || {};
for (const key in extras) {
  properties[key] = extras[key];
}

if (!data.processPersonProfile) {
  properties.$process_person_profile = false;
}

const url = API_HOSTS[data.region] + '/i/v0/e/';
const body = JSON.stringify({
  api_key: data.projectToken,
  event: eventName,
  distinct_id: makeString(distinctId),
  properties: properties
});

log('POST ' + url + ' ' + body);

sendHttpRequest(url, {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  timeout: 5000
}, body).then(function(result) {
  log('Response ' + result.statusCode + ' ' + result.body);
  if (result.statusCode >= 200 && result.statusCode < 300) {
    data.gtmOnSuccess();
  } else {
    data.gtmOnFailure();
  }
}, function(error) {
  log('Request failed: ' + error.reason);
  data.gtmOnFailure();
});


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://us.i.posthog.com/"
              },
              {
                "type": 1,
                "string": "https://eu.i.posthog.com/"
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
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
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
  }
]


___TESTS___

scenarios: []


___NOTES___

Created by PostHog. Source and issues: https://github.com/PostHog/posthog-gtm-template-server
