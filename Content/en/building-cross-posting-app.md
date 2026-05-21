---
author: Igor Ferreira
title: I'm Building a Cross-Posting App
description: The problem, the idea, and the challenges of building PostPortuguese
date: 2026-05-21
tags: PostPortuguese, iOS, Mastodon, Bluesky, Threads, cross-post
published: true
language: en
---

# I'm Building a Cross-Posting App

I found myself doing something that felt ridiculous: copying and pasting the same post into three different apps, one after another.

Mastodon. Bluesky. Threads.

Three platforms. Same content. Three times the effort. And somewhere between the second and third paste, I thought: someone should fix this. And then I thought: why not me?

So here we are.

---

## The problem

I've been on the fediverse for a while now, and I genuinely enjoy it. But the reality is that not everyone I know is on Mastodon. Some are on Bluesky. Some haven't left Threads (or Instagram, or whatever Meta is calling things these days). And if I want to be present across all of them, I have to post everywhere, which is tedious.

I know there are some tools out there that handle this. I've tried a few.

I wanted something that felt native to the platforms, not a lowest-common-denominator solution that strips everything interesting away. Each of these platforms has its own personality. Bluesky has its threading model. Mastodon has content warnings and language settings. Threads is its own thing. A good cross-posting tool should know all of that and handle it quietly in the background.

---

## What I'm imagining

At its core, PostPortuguese is dead simple: you write your post once, you hit send, and it goes everywhere. But the details matter.

Here's what I'm thinking about:

**Text posts with language support.** This one feels small but I think it's important. If you're writing in Portuguese (yes, the name is a clue), or French, or Japanese, the platform should know that. Mastodon and Bluesky let you tag the language of a post, and it helps with discoverability in local timelines. I want to support that properly.

**Image posts with alt texts.** Accessibility is not an afterthought. If you're sharing photos, you should be able to write alt text once and have it go to all platforms that support it. No excuses for skipping this.

**Threads.** Not the Meta app, I mean threaded posts. Long-form thoughts broken into a chain of linked posts. All three platforms support this in some way, and the app should handle the linking and sequencing automatically across all of them.

**Post history.** Once you've posted, you should be able to look back and see what you shared, and jump directly to any platform to check how it's doing. Likes, replies, boosts, that kind of thing. The app won't replace the native apps, but it should make it easy to get there.

---

## Challenges

Honestly? There are a few.

The API situation across three platforms is not trivial. Mastodon's API is well-documented and fairly straightforward. Bluesky uses the AT Protocol, which is newer and has its own quirks. Threads has a Meta-flavored API that I haven't dug into fully yet. Getting all three to behave consistently under one interface takes some careful thinking.

Authentication is another one. Signing into three different accounts, handling tokens, refreshing sessions... it's not glamorous work but it's the kind of thing that, if done badly, makes the whole app feel flaky.

And then there's the question of failure handling. What happens if one platform is down and the others succeed? How do you communicate that clearly without making the experience feel broken? And how do you handle the different character limits across platforms?

---

## So what?

I've started to put some pieces in place. And I plan to post more about the journey as it evolves. This app may reach the store in the near future (once I figure some things out). But... Let's see.
