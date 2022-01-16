---
author: "Aashray"
description: "A few words here and there about what I'm up to."
title: "The Defining Feature of Rust"
date: 2022-01-09T20:17:44-08:00
draft: false
---

The last time [I talked about rust](/posts/sum-types-and-null-in-rust/), I introduced one example of how 
the language developers have attempted to right the memory safety woes of programming languages of the past
introducing sum types into the rust language to explicitly differentiate null values from non-null values,
as opposed to the traditional C-style approach of a special NULL value that is assignable for any pointer.

This was just a taste of the efforts the rust developers have made to turn memory safety bugs into compilation
errors, rather than how they tend to manifest in other lanagues, which is in the form of often disastrous
runtime errors.

I wouldn't say its hyperbolic to say ownership is **the defining characteristic of rust**, and if you don't trust my word, you can listen to the folks who have written rust's ubiquitous [reference book](https://doc.rust-lang.org/book/title-page.html)

    Rust’s central feature is ownership.

### Let's talk about mutability

Before we get into what exactly ownership is, it's worth mentioning a small, but extremely important nuance of rust.
Compared to other C-style languages, where values are mutable by default, rust instead enforces **immutability by default**,
which means that values implicitly cannot be changed from their initialized value. For example, the code below is invalid.

![immutable_bad_code](/immutable_bug_code.png)

When we try to compile this, we get an error like below, since we tried to double assign an immutable variable.

![immutable_error](/immutable_bug_err.png)

Unlike languages like C or C++, where a variable is mutable unless we explicitly mark it as const, rust variables
are implicitly immutable. To fix the above code we would mark the value explicitly as mutable, like below.

![mutable_good_code](/immutable_bug_code.png)

More about rust immutability can be learned from the [rust book](https://doc.rust-lang.org/book/ch03-00-common-programming-concepts.html).

### What is ownership

Ownership is rusts' attempt to quell the problems that occur when different scopes of a program are mutating shared
data. Scope can be described as "the part of a program where a particular value exists". For example below, the variable
a defined within the if block is scoped to that if block only, as it is defined within it and will no longer exist past
that if block.

![scope_basic](/scope_basic.png)

For local values, that is, values of a fixed size that are defined statically (like x, y, and z above) the scope
of these values is to the function in which they are defined. This is different from dynamically-allocated values, such
as a String (which is variable-length and cannot be statically allocated, unless it is a fixed-length string literal),
which are allocated on the runtime heap, which can have a longer-living scope by maintaining a pointer to the value
and sharing this between different scopes.

The challenge of dynamically allocated values is that we are sharing the same data between different scopes, and what one
scope does to the value could be completely unknown to another, and have dramatic damage. The quintessential example of
this is a null pointer error, where one scope tries to dereference a pointer, but unbenknownst to it, another scope has already deleted this value.

Sharing data between scopes is  often is a problem in multi-threaded programs, but can manifest in any program where
memory is managed manually (not by a runtime garbage collector) and different scopes share mutable values via pointers.

Rust approaches the passing of values between scopes in an entirely different way, consider the case below.

![move_string_err](/move_string_err.png)

As we can see, we are able to create an integer, and then create a second integer by assigning it the value of the first
integer. On the other hand, when we try to do the same procedure for a String, we get an error when we tried to use the
original value.

![move_err](/move_err.png)

What this error is saying that you've **moved** the value of s1 to s2, and thus s1 can no longer be referenced, and this is
the key too all of rust's ownership rules. When you have a value that is **Copyable**, like a statically allocated type (where all data for the value is on the stack), we can copy the existing value on the stack when assigning this value
to a new variable. For Strings and other heap-allocated types, the value consists of two parts (one on the stack, one on the
heap). This is best understood from the visual below.

![move_result](/move_result.png)

The values of s1 and s2 consist of a pointer to a heap memory address, and a length value, which is on the stack frame, but
the bytes that make up "hello" are on the heap. If we were to allow making copies of strings, then we would have multiple variables which are able to mutate shared state, so instead of copying, we move the value, and render the original unusable. This way, we can only ever have a single value and scope that owns the heap memory, and can mutate it.

It's worth pointing out explicitly that passing values to a function that are not copyable has the same semantics as above, like the below example.

![move_no_return](/move_no_return.png)

In this case, the function we passed s1 to is now the owner of this value, and referencing s1 further after this will cause a similar compilation error. To move a value to a function and get ownership back, we must return this value in the function we moved it to, like below

![move_and_return](/move_and_return.png)

### References and Borrowing

Move semantics ensures that heap-allocated memory can't be mutated in more than a single scope, as well as by a single variable. However, there are times when we would want to share immutable data on the heap, or allow for some safe mutation in another scope, without moving a value entirely to that scope. For these cases, we use **references**. References in rust are much like C or C++, we use the & operator to indicate we are passing a value by reference. The main difference with rust references is they are immutable by default. Consider below.

![pass_ref](/pass_ref.png)

Firstly, note the parameter difference for the function, it is now of type &str, which is what is called a string slice in rust. It is a reference to a string, meaning it points to the same memory address as the original String, and can be read in the function it is passed to by reference, but it can NOT be mutated by that function. We can create as many immutable referneces to a value as we want and it will not cause a move of the original value. Immutable references allow for **borrowing** of values in rust, without violating its rules of memory safety.

We can also create **mutable references**, which allow for some modification of the reference's underlying value. Consider the below example, where we pass a mutable reference to a String, and are able to modify it in the scope of the mutable reference, while maintaining ownership in the calling scope.

![modify_mut_ref](/modify_mut_ref.png)

Unlike immutable references, we can only have a single mutable reference in any scope. This is similar to how we move values to avoid having multiple different mutable variables of the same memory in a single scope, so we can let other scopes mutate memory with references, while stil ensuring rust ownership's core tenant that there can never be multiple variables in the same scope, mutating the same value.

### Why does this even matter?

Having such a strict approach to ownership of memory means that you can write rust code without ever worrying the value you're holding may have been pull out from under you. Similarly to how sum types let you make sure you didn't miss checks on a value being garbage or not at compile time, ownership makes sure you haven't allowed for any scenarios at runtime where memory can be invalidated in one scope, and used in another, at compile time! There's no situation in rust where, at runtime, a String or some other dynamically allocated type that you own could be corrupted by someone else, which entirely rids an enormous and disastrous segment of memory safety issues that C and C++ are rife with.