# Systematic Program Design

This repository is a working course archive for the UBCx / edX
`Systematic Program Design` course.

It contains:

- week-by-week course materials
- starter files
- reference solutions
- personal solutions
- final-project work
- design recipe reference material

## What This Repository Is

This is not a single application or library. It is a structured study
workspace organized around the progression of the course.

The repository includes:

- exercises from `Week-01` through `Week-11`
- problem-bank and practice-problem files
- quizzes and lecture examples
- end-of-course project work in [`final/`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/final)
- design-recipe reference documents:
  - [`recipes.pdf`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/recipes.pdf)
  - [`recipes.txt`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/recipes.txt)
  - [`recipe-checklist.pdf`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/recipe-checklist.pdf)

## Repository Layout

The repository is organized primarily by week.

```text
.
├── Week-01
├── Week-02
├── Week-03
├── Week-04
├── Week-05
├── Week-06
├── Week-07
├── Week-08
├── Week-09
├── Week-10
├── Week-11
├── final
├── recipes.pdf
├── recipes.txt
└── recipe-checklist.pdf
```

### Weekly Folders

Each `Week-*` folder typically contains a mix of:

- lecture examples
- starter exercises
- reference solutions
- personal solutions
- problem-bank exercises
- quizzes

The structure inside a week often reflects the lesson sequence rather than a
single uniform file layout.

### Final Folder

The [`final/`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/final)
folder contains larger integrative work, including:

- [`space-invaders-starter.rkt`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/final/space-invaders-starter.rkt)
- [`space-invaders-my-soliution.rkt`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/final/space-invaders-my-soliution.rkt)
- [`ta-solver-starter.rkt`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/final/ta-solver-starter.rkt)
- [`ta-solver-my-solution.rkt`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/final/ta-solver-my-solution.rkt)

## Naming Conventions

Most exercise files follow a consistent naming pattern:

- `*-starter.rkt`
  Original exercise starter file.
- `*-solution.rkt`
  Reference solution.
- `*-my-solution.rkt`
  Personal solution.
- `*-v1.rkt`, `*-v2.rkt`, `*-v3.rkt`, etc.
  Incremental lecture or development versions.

This makes it easy to:

- work from the starter file
- compare against the reference solution
- keep a separate personal implementation

## How To Open and Run the Files

This repository is centered around DrRacket and the HtDP teaching languages.

### Recommended Tooling

Use:

- Racket
- DrRacket

Many files are best opened directly in DrRacket rather than treated as plain
text source files.

### Important Note About File Format

Some `.rkt` files in this repository were saved in DrRacket’s editor format.
When viewed as plain text, these files can look noisy or binary-like.

For example, some files explicitly state that they should be opened in DrRacket.

So the practical rule is:

- if a file looks unreadable in a plain text editor, open it in DrRacket

### Language Levels

The repository uses HtDP teaching languages recorded in file metadata, such as:

- `htdp-beginner-reader`
- `htdp-beginner-abbr-reader`
- `htdp-intermediate-reader`
- `htdp-intermediate-lambda-reader`

In most cases, the language level is already embedded in the file, so opening it
in DrRacket is enough.

### Common Libraries

Some files also depend on course libraries such as:

- `2htdp/image`
- `2htdp/universe`

These are standard parts of the Racket / HtDP environment.

## Recommended Workflow

The most useful way to work with this repository is:

1. open a `*-starter.rkt` file in DrRacket
2. solve the problem in your own `*-my-solution.rkt` file
3. compare your result with the corresponding `*-solution.rkt`
4. use the recipe references while designing data definitions and functions

For larger topics, it is also useful to read the `v1`, `v2`, `v3`, etc.
progression files to see how the course builds a solution step by step.

## Course Progression

At a high level, the repository tracks the progression of the course from basic
function design to more advanced recursive and generative techniques.

Broadly:

- early weeks focus on expressions, function design, tests, and simple data
  definitions
- middle weeks focus on lists, world programs, trees, BSTs, and mutually
  recursive data
- later weeks focus on abstraction, folds, accumulators, generative recursion,
  backtracking, and graphs
- the final material applies the recipes to larger interactive programs and
  solver-style problems

## Highlights

Some notable areas in this repository:

- world and universe programs in the Week 3 material
- list and tree design problems in Weeks 4 through 7
- abstraction and fold work in Week 8
- fractals and sudoku in Week 9
- accumulator and worklist patterns in Week 10
- graph traversal and cyclic data in Week 11
- final project work such as Space Invaders

## Suggested Starting Points

If you are exploring the repository for the first time, these are good entry
points:

- [`Week-01`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/Week-01)
  for the basic design recipe
- [`Week-03`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/Week-03)
  for world programs
- [`Week-06`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/Week-06)
  for trees and mutually recursive data
- [`Week-09`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/Week-09)
  for generative recursion and sudoku
- [`Week-11`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/Week-11)
  for graph problems
- [`final/`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/final)
  for larger end-to-end exercises

## Credits

These materials were taken from the course
["Systematic Program Design" on edX](https://learning.edx.org/course/course-v1:UBCx+SPD1x+2T2015).

Credit goes to [spamegg](https://github.com/spamegg1) for collecting and
organizing the starter files.

The [`recipes.pdf`](/Users/leonidkuznetsov/dev/study-and-research/systematic-program-design/recipes.pdf)
file was compiled into PDF form by
[Ashine Foster](https://github.com/AshineFoster).

## License

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
