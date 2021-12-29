---
author: "Aashray"
description: "A few words here and there about what I'm up to."
title: "Sum Types and Null in Rust"
date: 2021-12-29T11:17:20-08:00
draft: false
---

Sum types are definitely a step in a different direction for rust from C-style languages. 
They let you define an *enumeration of types*, and then create instance of these enumerations which are
one of the set of types they specify. See an example below (of a binary search tree definition)

    pub enum Tree<T> {
        TreeNode(T, Box<TreeNode<T>>, Box<TreeNode<T>>),
        Nil
    }

What we see here is an example of using an enum to indicate that an instance of a Tree can take on 
one of a set of fixed types, either a TreeNode, or Nil. Let's also make it explicitly clear that 
Nil is not a primitive type of rust, and rather, this is a locally defined type, and is distinct from what 
we think of as Nil/Null in other languages.

The above sum type can be thought of as similar to the 
below C++ structure definition

    template <typename T> struct TreeNode {
        TreeNode* left,
        TreeNode* right,
        T         val
    };

The difference being, in C++, we would imagine that the above structure will always have the 
same concrete type (TreeNode), but can possibly be a null pointer (having no useful value). In rust, 
the equivalent to this is to instead have different concrete types for a non-null vs. null TreeNode, 
and wrap these into a single enumerable sum type.

In fact, the idea of sum types highlights another big difference between rust and many other languages, 
which is that there is no actual null value as we tend to understand it. 

This is an amzing thing! After all, Tony Hoare, the Turing award winner, developer of one of the first comprehensive
[type systems](https://en.wikipedia.org/wiki/ALGOL) and the man credited for creating the null pointer, has called 
it his "one billion dollar mistake", for all of the resulting errors, vulnerabilities, and crashes it has lead to 
in systems based on languages which include null references, and do not have any defined behavior for these cases.
It's all because in languages with nullable types, we don't truly know what something is, and we need to always be wary of
whether it truly can be treated as the concrete type it specifies, or not. It's like hiding all of your bleongings in
trash bags, not knowing whether the contents of a bag are going to be something useful, or just a bunch of trash!

This is where rust has remedied much of this disaster, as failing to distinguish between the different concrete 
types of a sum type, such as an Option, causes a compile time error, rather than the run time errors we are used 
to in languages like C or C++ where a null pointer check is missed. That is, an instance of a rust sum type is
explicitly (from its type) some value of use, or some garbage value, but can be known as one or the other just from
its underlying type. No more trash pretending to be treasure!.

To understand this best, it's best to look at rust's ubiquitous Option sum type. It is the de-facto sum type used to
represent values in rust that may or not exist.

    pub enum Option<T> {
        None,
        Some(T)
    }

This is just a more generalized form of what we have defined in our TreeNode enum. Option is a sum type, where we 
either have a value T with type Some, or we have no value with type None. The ambiguity of whether a value with a
concrete type X having an underlying value that can actually be interpreted as this type is completely gone!

Consider the equivalent to this sum type in C++, which instead has a single type with nullable values. If we were to 
miss our null pointer check for case below, then the behavior we get is undefined, and is only exposed at runtime.

    int* bad_value = buggy_function_sometimes_null();
    int* good_value = buggy_function_sometimes_null();

In comparison, rust won't ever even allow garbage values to masquerade as a valuable type like this case, see the alternative
below using options vs a nullable type.

![option_type_bad_code](/option_type_bad_code.png)

Then, if we have a case of some buggy code like above, where we try to use some value that is "null" (or better said, 
an instance of the None type), the **compiler** will stop us, and require we explicitly ensure that
we are interacting with the correct concrete type. 

![option_type_error](/option_type_error.png)

No longer can a missed null check slip by! (see the fixed code below)

![option_type_good_code](/option_type_good_code.png)

[Some more good reading](https://blog.waleedkhan.name/union-vs-sum-types/) about union and sum types, one of the many functional programming features to grow into heavy favor