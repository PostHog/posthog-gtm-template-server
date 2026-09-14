# PostHog template for Google Tag Manager (server-side)

A Google Tag Manager **server container** custom template that sends events to the [PostHog capture API](https://posthog.com/docs/api/capture).

## Install

In your server container, go to **Templates > Tag Templates > Search Gallery** and search for PostHog.

## What it does

Takes the event that reached your server container and posts it to `/i/v0/e/` on PostHog Cloud.

| Field | Default |
| --- | --- |
| Event name | The incoming `event_name` |
| Distinct ID | `user_id`, falling back to `client_id` |
| Properties | Every key of the incoming event, plus anything you add in the tag |

Turn off **Create or update a person profile** to send the event as [anonymous](https://posthog.com/docs/data/anonymous-vs-identified-events). This sets `$process_person_profile` to `false`, which affects billing.

## Setup

1. Create a tag and set your project API key and region.
2. Trigger it on the client events you want in PostHog.
3. Check the response in Preview mode. Turn on **Log requests and responses** while you test, and turn it off before you publish.

Find your project API key in [your project settings](https://us.posthog.com/settings/project). It starts with `phc_`.

## Timestamps

The tag does not send a `timestamp`, so PostHog uses the time it receives the event. For a backfill or a queued pipeline where that gap matters, add a `timestamp` property in ISO 8601 format.

## Self-hosted instances

Not supported. Google requires request URLs to be declared in the template, so only the US and EU Cloud hosts are allowed.

## Contributing

Open an issue or a pull request. If you change `template.tpl`, add a new entry at the top of the `versions` list in `metadata.yaml` with the new commit SHA and a change note. The gallery serves the revision that `metadata.yaml` names.

## License

Apache 2.0, as required for Google Tag Manager gallery templates.
