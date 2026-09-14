# PostHog template for Google Tag Manager (server-side)

A Google Tag Manager **server container** custom template that forwards events to the [PostHog capture API](https://posthog.com/docs/api/capture).

> **Status: not published.** This template has not been submitted to the Community Template Gallery and has not been tested in a real container. See [Before submitting](#before-submitting).

## What it does

Takes the event that reached your server container and POSTs it to `/i/v0/e/` on PostHog Cloud.

| Field | Default |
| --- | --- |
| Event name | The incoming `event_name` |
| Distinct ID | `user_id`, falling back to `client_id` |
| Properties | Every key of the incoming event, plus anything you add in the tag |

Turn off **Create or update a person profile** to send the event as [anonymous](https://posthog.com/docs/data/anonymous-vs-identified-events). That sets `$process_person_profile: false`, which affects billing.

## Setup

1. Add the template to your **server** container.
2. Create a tag, set your project API key and region, and trigger it on the client events you want in PostHog.
3. Use Preview mode to check the response. Turn on **Log requests and responses** while testing, and turn it off before publishing.

## Timestamps

The tag does not send a `timestamp`, so PostHog uses the time it receives the event. For a backfill or a queued pipeline where that gap matters, add a `timestamp` property in ISO 8601 format.

## Self-hosted instances

Not supported. Google requires request URLs to be declared in the template, so only the US and EU Cloud hosts are allowed.

## Before submitting

This repository is not ready for the [Community Template Gallery](https://developers.google.com/tag-platform/tag-manager/templates/gallery). Outstanding work:

- [ ] Import `template.tpl` into the GTM template editor and confirm it loads without validation errors.
- [ ] Add a brand thumbnail to the `brand` block in `___INFO___`.
- [ ] Write test scenarios in `___TESTS___`, which is currently empty.
- [ ] Test against a real server container and a real PostHog project.
- [ ] Replace the placeholder `sha` in `metadata.yaml` with the commit SHA to publish.
- [ ] Accept the gallery Developer Terms of Service in the template editor's **Info** tab.
- [ ] Make this repository public with Issues enabled, then submit at [tagmanager.google.com/gallery](https://tagmanager.google.com/gallery).

## License

Apache 2.0. Required by Google for gallery templates, and not the license PostHog uses elsewhere.
