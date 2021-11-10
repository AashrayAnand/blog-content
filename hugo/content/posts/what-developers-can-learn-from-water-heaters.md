---
author: "Aashray"
description: "A few words here and there about what I'm up to."
title: "What Developers Can Learn From Water Heaters"
date: 2021-11-10T10:17:53-08:00
draft: false
---

***I’ve never really understood how a water heater works. It may sound dumb, but it’s the truth.***

![water heater](water_heater.jpg)

*I know that I have a water heater, I know that I pay a utilities bill for my water heater, and I know that I can rest assured at night that when I shower it will be with hot water, but how that happens has never been something I’ve known or thought much about.*

Unfortunately, my water heater broke the other day, and the painful reality of the situation hit when I tried to take my nightly shower, and after 5 minutes, the water was still cold. 

I guess this isn’t exactly a glowing compliment for my water heater, nor does it seem to jive with the title of this blog, but software engineers really could learn a thing or two from water heaters, because not too much later that night, the water heater was fixed by yours truly.

That’s right! You probably shouldn’t start calling me to install your HVAC systems any time soon, and please don't quiz me on all the parts in the heater, but fixing it was a matter of 5 minutes and following some very simple instructions, and that’s why software engineers could learn something from water heaters.

![heater parts](/heater_parts.jpg)

### Services should be like water heaters

The best services are the ones that work, that let their clients live in a state of blissful ignorance about their internals, and in the occasional case of failure, are easily fixable without forcing the client to know any more than the bare minimum.

On my team, [Azure SQL DB](https://azure.microsoft.com/en-us/products/azure-sql/database/), our service is databases. Customers come from every industry and span the gamut of business sizes, from mom-and-pop shops to the Wal-Marts and Starbucks of the world, and just like how every house has a water heater and everyone expects theirs to work, every customer should be rest assured their databases work and they don’t have to think twice about it.

Creating these databases internally consists of countless steps, like placement and load balancing of the sql server processes on our clusters, storage allocation, DNS record creation and much more. Each one of these steps is like a part of my water heater, and just like how I don't care what my thermocouple does or what metal its made of, customers shouldn't think twice about these parts of their database, and should just stick to writing
their SELECT statemenets.

Now obviously, the reality is always a bit harsher than the hope. Like Joel Spolsky [said]( https://www.joelonsoftware.com/2002/11/11/the-law-of-leaky-abstractions/)

*"all non-trivial abstractions, to some degree, are leaky."*

Sometimes the pilot light is going to go out. Maybe part of the burner is rusted and now your heater can’t get past medium heat, it’s just not always going to be right when the problem being solved isn’t simple. At the very least though, when things go wrong, they should be fixable without the clients leaving their blissful ignorance, the same way I was able to fix my water heater with a couple matches and a flashlight.

That's why we developers could all learn a bit from one of the greatest services of all, and for that reason I leave you what I'd call **the water heater test**

1. Does your service pretty much just work? This could be measured in [9's](https://en.wikipedia.org/wiki/High_availability#:~:text=Availability%20is%20usually%20expressed%20as%20a%20percentage%20of%20uptime%20in%20a%20given%20year), customer incident volume, or whatever else makes most sense for your case, but whatever that is, can you confidently say your services' availability is akin to a water heater?
2. Can your service be used by a dummy? How much do your clients need to know about its internal details to utilize it well? If it's anything harder than turning on a water heater, it could be better.
3. When things go wrong, does your service self-heal, or do what it can to lead your clients back to a good state? Do you find your clients reverse engineering your service to fix issues, or are the set of issues and fixes straightforward, like the instructions on a water heater?