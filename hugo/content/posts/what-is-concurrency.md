---
title: "What Is Concurrency"
date: 2022-02-13T14:09:15-08:00
draft: false
---

Humans beings are the masters of doing things concurrently, so it's no wonder we found a way to build computers and software to do the same. In the same way that you can switch between browsing your twitter feed and drinking your morning, your computer is surgically balancing countless independent tasks at any given time, constantly ensuring it is making the best use of its time, but sometimes, running into the same problems humans do, when we try to juggle too many obligations, without the proper checks and balances.

I'm going to try to explain what exactly concurrency is, in a way that applies as much to computers as it does to people, and start the groundwork for some upcoming posts where I dig into the fundamental concurrency primitives and problems of computer science.

* Multiple images used in this post are originally sourced from the amazing book, [Concurrency in .NET](https://www.manning.com/books/concurrency-in-dot-net), by Riccardo Terrell.

### What is concurrency?

Concurrency is, the act of executing multiple independent tasks at the same time. Concurrency doesn't necessitate multiple tasks are executing simultaneously at **a single point in time**, but rather, that they interleave in execution over **continuous interval of time**. We may say we are concurrently making coffee and browsing the internet, if there is an interval of time where we start brewing coffeee, followed by pulling out our phone and scrolling through the timeline, before pouring the finished coffee into a mug. This is because we interleaved the steps of these two tasks over one another.

![single-core concurrency](/single_core_concurrency.png)

For someone who is not familiar with a processor, or a "core", it can best be explained as the brain of the computer. Every application boils down to a sequence of instructions, such as adding numbers, comparing values, or some other steps, which are handled by processors.

A single core machine, therefore, is a machine which has 1 brain, and at a single point in time, is executing instructions from one "thread of execution". A thread of execution can be thought of as one of the many different sequences of instructions for one of the programs running on the computer. There is a thread of execution for your web browser, your music player, your video games, and everything else. Every program has at least one thread of execution, which consitutes what the program is doing, however, a program can also have multiple threads of execution, if it wants to concurrently accomplish multiple tasks. For example. Document editors like Microsoft Word do exactly this, and this is why we can keep typing without the program freeze when we save our document, as there are separate threads of execution, concurrently saving the contents of the file to your hard drive, and accepting user input.

Going even further than a single applications, our computers as a whole are a concurrent system. Although we are made to believe the illusion that there are countless tasks which at a single point in time are all running, this isn't actually the case. Rather, our computers execute a process which is called **context switching**, where the currently executing application switches at periodic intervals slicing small bits of time for each application to do any processing work it needs, before letting others do work and remaining idle. Of course, computers have a much faster brain than us, so they can switch between tasks every few milliseconds without breaking a sweat.

### True Concurrency

![true concurrency](/true_concurrency.png)

It would be remiss not to mention what is sometimes referred to as **true concurrency**. This is a term for modern computing hardware, which has more than one processing core, and therefore actually CAN be executing mutiple threads of execution at a single point in time (a 4 core machine, for example, can execute 4 tasks at a single point in time). Though this is a hardware innovation that enables what had previously only been done by context switching between tasks, the properties of processes executing on truly concurrent hardware
are still much like traditional concurrency.

### Mutual Exclusion

Imagine if you and your roommate try to concurrently brew up your morning coffee. You start boiling water and placing some coffee grounds into the machine, before adding in the water and waiting for it to finish. Your roommate joins in midway, pouring his (different) coffee grounds, and adding more water to the machine, causing it to overflow! 

![coffee spill](https://media.giphy.com/media/9lEGNc2hPkmevAciHq/giphy.gif)

Concurrency can cause some headaches between the tasks that are operating concurrently, especially when they **share resources with one another**. This is what we call a problem of **mutual exclusion**, where we need to ensure that the uses of a shared resource by concurrent tasks are mutually exclusive of one another. Roommates should not use the coffee machine while it is under use by other roommates. For this problem, one may think about the light that flashes on most coffee makers when they are in use, which warns others not to try and use them until the light flashes off. For even stronger mutual exclusion, we may consider an office coffee machine, where the machine is locked into a single coffee brewing sequence, not allowing another to start until the current one is finished.

The downside of mutual exclusion is, the more things you share, the more time you're waiting to get a hold of those things. The balance between mutual exclusion and minimizing waiting is an ever-important problem when writing concurrent programs.

### Synchronization

Now that we've recognized the problem to solve of mutual exclusion, it's worth bringing up another similar, yet more nuanced set of issues, known as synchronization problems.

Sometimes, we not only want to ensure that shared resources are not accessed by multiple tasks concurrently, but also, that a specific order is enforced on this access. Imagine we are running a pasta restaurant, with a few employees who hold very distinct roles.

We have a waiter, who takes orders, and brings finished plates from the kitchen to tables. We have a chef, who prepares the noodles for all the dishes, and a sous chef, who prepares the meats and vegetables, and does quality control before the waiter serves plates. Imagine if the chef cooking noodles started plating his noodles without letting the sous chef know, and the waiter started grabbing these unfinished plates, bringing customers dishes with nothing on them but noodles! Not to mention an even more disastrous fate, the waiter taking a plate from the kitchen and serving it to a table, before the sous chef had a chance to inspect the dish and find a ball of hair in it!

![idiot sandwich](https://media.giphy.com/media/3o85xnoIXebk3xYx4Q/giphy.gif)

This is a case where there are not only shared resources (the plate which the chefs add ingredients to, and the waiter takes from th kitchen to the table), but also an implied order in which the operations on this resource must be done, which is what we refer to as a synchronization problem.

One way this problem could be solved is by adding conditions to the shared resources, indicating who is allowed to access them. For example, the chef who prepares noodles could leave all plates with noodles, waiting for the remaining ingredients on one table, from which only the sous chef takes plates, while the waiter takes plates from a different table, which the sous chef adds plates to after they are good to go.

Another solution would be message passing, for example, only letting the sous chef attend to plates which the chef has handed to him, and likewise, the waiter only to plates handed to him by the sous chef.

Synchronization, much like mutual exclusion, is a complexity added in environments where we don't just have one sequence of steps under way, and in a similar vein, requires solutions that find a way to block one sequence or another at the appropriate times, such that they can all interleave with one another in harmony.

### What's Next

I didn't want to get too into the details with this post and my hope is that pretty much anyone, even those in non-software careers could digest the ideas of concurrency, an intuitive part of our existence as people that is equally integral to the software systems we interact with.

Going forward, I'm going to introduce some of the primitives that languages like C++ and C# provide for enabling concurrency and syncronization and how they work under the hood, as well as some classical problems that often manifest in real life systems.