<div align="center" style="font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; line-height: 1.6;">

  <h1 style="margin-bottom: 0.2em;">Julia Plotting Playground</h1>
  <p style="font-size: 0.95rem; max-width: 760px; margin: 0 auto;">
    A minimal, extensible repository showcasing plotting in <strong>Julia</strong> using
    <strong><a href="https://github.com/JuliaPlots/Plots.jl" target="_blank">Plots.jl</a></strong>.
    The repository currently includes <strong>line plots</strong> and <strong>histograms</strong> via
    <code>line.jl</code> and <code>histogram.jl</code>.
    Future extensions can be added as new plot modules (e.g., pie charts, scatter plots, etc.).
  </p>

  <p style="font-size: 0.85rem; color: #666; margin-top: 0.5em;">
    Built with Julia, Plots.jl, and selectable rendering backends (GR / PythonPlot).
  </p>

</div>

<hr />

<!-- ========================================================= -->
<!-- Table of Contents                                        -->
<!-- ========================================================= -->

<ul style="list-style: none; padding-left: 0; font-size: 0.95rem;">
  <li>• <a href="#about-this-repository">About this repository</a></li>
  <li>• <a href="#install-julia-and-plotting-packages">Install Julia and plotting packages</a></li>
  <li>• <a href="#why-the-first-run-can-take-tens-of-minutes">Why the first run can take “couple of minutes”</a></li>
  <li>• <a href="#running-with-vs-code-recommended">Running with VS Code (recommended)</a></li>
  <li>• <a href="#running-without-vs-code-terminal-cmd-git-bash">Running without VS Code (Terminal / cmd / Git Bash)</a></li>
  <li>• <a href="#outputs-where-images-are-saved">Outputs (where images are saved)</a></li>
  <li>• <a href="#line-plots-module-linejl">Line plots module (<code>line.jl</code>)</a></li>
  <li>• <a href="#histogram-plots-module-histogramjl">Histogram plots module (<code>histogram.jl</code>)</a></li>
  <li>• <a href="#implementation-tutorial-video">Implementation tutorial video</a></li>
</ul>

---

## About this repository

This repository is a small, practical starting point for plotting in Julia using **Plots.jl**.

Current examples:

- `line.jl` — multiple line-plot demonstrations (multi-series plots, markers, subplots, tiled layouts, and a CSV-driven plot).
- `histogram.jl` — a histogram “toolbox” (binning rules, normalization, categorical histograms, overlays, and a CSV-driven histogram).

---

## Install Julia and plotting packages

### 1) Install Julia

Install **Julia 1.10+** (this repository was developed with Julia 1.12.x).

Recommended approach:

- Install Julia from the official Julia downloads page.
- Ensure the `julia` executable is available from your terminal.

Quick verification (any terminal):

<pre><code>julia --version</code></pre>

If a version prints, Julia is installed correctly.

---

### 2) Install packages in Julia (Pkg)

Julia uses **Pkg** (its built-in package manager). For this repository, you will install the plotting stack once, and then run the scripts.

From the Julia REPL (run this in the repo root folder):

<pre><code>julia
julia&gt; import Pkg
julia&gt; Pkg.activate(".")
julia&gt; Pkg.add(["Plots","StatsBase","CSV","DataFrames","Downloads","PythonPlot"])</code></pre>

What this does:

- `Pkg.activate(".")` creates/uses a project environment in the current folder (the repo root).
- `Pkg.add(...)` installs the required packages into that environment.
- As a side effect, Julia generates (or updates) the environment files:
  - `Project.toml` (direct dependencies)
  - `Manifest.toml` (locked dependency graph)

This repository does <strong>not</strong> include `Project.toml`, `Manifest.toml`, or `.vscode/` by design (to avoid machine-specific paths and to keep the repo lightweight). You generate them locally using the steps above.

---

### 3) Dependencies used in this repository

The scripts use these packages and standard libraries:

- **Plots** — main plotting interface.
- **GR** — commonly used rendering backend (selected with `gr()`).
- **PythonPlot** — optional backend (selected with `pythonplot()`).
- **StatsBase** — histogram utilities (counting, bin rules, etc.).
- **CSV** + **DataFrames** — reading and manipulating tabular datasets.
- **Downloads** — downloading CSV files directly from URLs.
- Standard libraries: **Random**, **Statistics**.

Backend note:
- If you use `pythonplot()`, Julia may create a Python environment (via PythonCall/CondaPkg) the first time you run it.

---

## Why the first run can take “couple of minutes”

It is normal (especially on Windows) for the **first** run of a plotting repository to take a long time.

This is typically caused by a combination of:

1. **Package downloads**  
   On first use, Julia downloads the packages you added via `Pkg.add(...)`.

2. **Artifact downloads (binary dependencies)**  
   Plotting stacks commonly require binary artifacts (e.g., GR runtime, fonts, image/video encoders). Julia downloads these artifacts the first time they are needed.

3. **Precompilation (JIT + caching)**  
   Julia compiles package code into cached `.ji` files. Plotting packages are large, so precompilation can be substantial.

4. **Backend initialization**  
   - With `gr()`, the GR runtime is initialized and cached.
   - With `pythonplot()`, Julia may also download and configure a Python distribution and dependencies (via CondaPkg / MicroMamba).

After this initial setup, future runs are typically much faster because packages, artifacts, and compiled caches are already present.

Practical advice:
- Run the package installation steps once, then run scripts normally.
- If the first run is slow, it is usually doing real work (downloads/precompile) rather than being stuck.

---

## Running with VS Code (recommended)

This repository supports a clean workflow in **Visual Studio Code** using the Julia extension.

### 1) Install VS Code and the Julia extension

- Install Visual Studio Code.
- Install the **Julia** extension (by the Julia VS Code team).

### 2) Open the repository folder

In VS Code:

- **File → Open Folder…** → select the repo directory (where `line.jl` and `histogram.jl` exist).

### 3) Create the Julia environment for this repo

1) **Open the Julia REPL inside VS Code**
- Press **Ctrl + Shift + P** to open the **Command Palette**
- Type: **Julia: Start REPL**
- Press **Enter**

You should now see a Julia REPL terminal open inside VS Code.

2) **Activate the repo environment and install dependencies**
In the Julia REPL, first make sure the working folder is the repository root (the folder you opened in VS Code). Then run:

<pre><code>import Pkg
Pkg.activate(".")
Pkg.add(["Plots","StatsBase","CSV","DataFrames","Downloads","PythonPlot"])</code></pre>

What you should expect:
- Julia creates/updates `Project.toml` and `Manifest.toml` in the repo folder (locally on your machine).
- All required packages are installed into that environment.
- The first install may take a while because Julia is downloading and precompiling packages.

---

### 4) IMPORTANT: Ensure VS Code is using the repo environment (fixes “StatsBase not found”)

If you can run `line.jl` but `histogram.jl` fails with:

- `ArgumentError: Package StatsBase not found in current path`
- or you see output like `Activating project at C:\...\ .julia\environments\v1.7`

then VS Code is running your file in the **global default environment** (e.g., `~/.julia/environments/v1.7`) instead of the **repo environment** you created in this folder.

Use the checks and fixes below.

#### A) Quick check (in the VS Code Julia REPL)

Run:

<pre><code>import Pkg
Base.active_project()</code></pre>

Expected result:
- The printed path should point to the repo, e.g. `<your-repo>\Project.toml`.

If you instead see something like:
- `C:\Users\...\ .julia\environments\v1.7\Project.toml`

then the repo environment is not active for your current VS Code session.

#### B) Activate the repo environment in VS Code

Option 1 (recommended): activate via the command palette

- Press **Ctrl + Shift + P**
- Run: **Julia: Activate This Environment**
- Select the repository folder (the folder that contains `Project.toml`)

Option 2: activate in the REPL

<pre><code>import Pkg
Pkg.activate(".")</code></pre>

#### C) Make sure VS Code is using the correct Julia version

If VS Code is launching Julia 1.7 (and activating `v1.7`), but you installed Julia 1.10+ separately, configure the Julia extension to use the newer executable:

- VS Code → **command palette** (ctrl + shift + p) → **Settings** → search for **Julia: Executable Path**
- Point it to your Julia 1.10+ `julia.exe`

You can verify the current Julia version in the VS Code REPL:

<pre><code>versioninfo()</code></pre>

---

### 5) Configure VS Code run settings (launch.json) to use the repo environment


#### Option A (UI-driven, recommended)

1) Open the **Run and Debug** panel (left sidebar)
2) Click **Create a launch.json file**
3) If prompted to select an environment, choose **Julia**
4) Select a template such as:
   - **Run active Julia file**

Then verify (or adjust) that:
- the script is the active editor file (`${file}`)
- the working directory is the repo folder (`${workspaceFolder}`)
- the environment used is the repo environment (points to `${workspaceFolder}`)

#### Option B (manual) — copy/paste `launch.json` (recommended if you want Ctrl+F5)

1) In the repo root, create a folder named:

<pre><code>.vscode</code></pre>

2) Inside `.vscode/`, create a file named:

<pre><code>launch.json</code></pre>

3) Paste the following **exact** content into `.vscode/launch.json`:

<pre><code>{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "julia",
      "request": "launch",
      "name": "Run active Julia file (repo env)",
      "program": "${file}",
      "cwd": "${workspaceFolder}",
      "juliaEnv": "${workspaceFolder}"
    }
  ]
}</code></pre>

What this configuration does:
- **Runs the currently active file** (e.g., `line.jl` or `histogram.jl`) via `"program": "${file}"`
- **Sets the working directory** to the repo root via `"cwd": "${workspaceFolder}"`
- **Forces the Julia environment** to be the repo environment via `"juliaEnv": "${workspaceFolder}"`

If you already have a `launch.json` created by VS Code, make sure it includes the two key lines above:

- `"cwd": "${workspaceFolder}"`
- `"juliaEnv": "${workspaceFolder}"`

---

### 6) Run the scripts

#### Run `line.jl`
1) Open `line.jl` in the editor
2) Press **Ctrl + Shift + P**
3) Type: **Julia: Execute Active File**
4) Press **Enter**

#### Run `histogram.jl`
1) Open `histogram.jl` in the editor
2) Press **Ctrl + Shift + P**
3) Type: **Julia: Execute Active File**
4) Press **Enter**

The scripts save PNG outputs (see the outputs section below).

#### Troubleshooting: `StatsBase` not found when running `histogram.jl`

If `line.jl` runs but `histogram.jl` fails with `Package StatsBase not found`, it means the file is being executed in an environment that does not have **StatsBase** installed (most commonly the global `~/.julia/environments/v1.x` environment).

Fix (recommended): activate the repo environment, then install dependencies there:

<pre><code>import Pkg
Pkg.activate(".")
Pkg.add(["Plots","StatsBase","CSV","DataFrames","Downloads","PythonPlot"])</code></pre>

Quick workaround (not recommended long-term): install StatsBase into the currently active environment:

<pre><code>import Pkg
Pkg.add("StatsBase")</code></pre>

#### How to run with **Ctrl + F5** (Run Without Debugging)
- Open `line.jl` or `histogram.jl`
- Press **Ctrl + F5**
- VS Code will run the active Julia file using the configuration above

Notes:
- **Ctrl + F5 works reliably** when:
  - the **Julia extension** is installed
  - the `.vscode/launch.json` exists
  - you opened the **repo folder** (not just a single `.jl` file)
- If VS Code asks which configuration to use, select:
  - **Run active Julia file (repo env)**
- If you see `Activating project at ...\.julia\environments\v1.x`, re-check the environment activation section above and confirm you are using the repo environment.

Optional (but strongly recommended):
- Run the environment setup once (in the VS Code Julia REPL):
<pre><code>import Pkg
Pkg.activate(".")
Pkg.add(["Plots","StatsBase","CSV","DataFrames","Downloads","PythonPlot"])</code></pre>
This ensures the repo environment exists before you start using Ctrl+F5.

---

## Running without VS Code (Terminal / cmd / Git Bash)

You can run everything using a terminal only.

### 1) One-time package install (creates the repo environment files locally)

From the repository root, open Julia and run:

<pre><code>julia
julia&gt; import Pkg
julia&gt; Pkg.activate(".")
julia&gt; Pkg.add(["Plots","StatsBase","CSV","DataFrames","Downloads","PythonPlot"])</code></pre>

This installs dependencies and generates `Project.toml` and `Manifest.toml` locally.

### 2) Run line plots

From the repository root:

<pre><code>include("line.jl")</code></pre>

### 3) Run histograms

From the repository root:

<pre><code>include("histogram.jl")</code></pre>

---

## Outputs (where images are saved)

Both scripts save figures to image files (PNG).

- Output location: by default, **the current working directory** at runtime.
  - In terminal runs, this is usually the repo root (unless you `cd` elsewhere).
  - In VS Code runs, it is usually the workspace folder.

If you want outputs in a dedicated folder, a common pattern is:

- Create `output/`
- Change `savefig(..., "output/plot.png")`

---

<section id="line-plots-module-linejl">

## Line plots module (`line.jl`)

This section documents the **line plot** examples implemented in `line.jl`.  
It is structured to be modular so you can add future plot modules without rewriting the README layout.

### Imports and backend selection

Key imports at the top of `line.jl`:

- `using Plots` — plotting interface
- `using Random, Statistics` — data generation and statistics
- `using CSV, DataFrames, Downloads` — CSV download + reading
- `pythonplot()` — selects the PythonPlot backend for Plots.jl (an alternative is `gr()`)

The file also sets a global default:

- `default(dpi=300)` makes saved figures high resolution by default.

### Helper function: GitHub “blob” link → “raw” link

`github_blob_to_raw(url)` converts URLs like:

- `https://github.com/.../blob/.../file.csv`

into:

- `https://raw.githubusercontent.com/.../.../file.csv`

This is necessary because CSV readers must download the **raw file contents**, not the GitHub HTML page.

### What `line.jl` generates

The script contains multiple independent blocks (`begin ... end`). Each block builds a plot and saves a PNG file.

#### 1) Multiple line plots on the same axes → `line_1.png`

- Uses `LinRange(0, 2π, 200)` to create a dense x-axis.
- Computes `sin.(x)` (broadcasted `sin`).
- Overlays multiple series using `plot!`:
  - `sin(x)`
  - `-sin(x)`
  - `x/π - 1`
  - a manually defined series with implicit x = 1:n
- Demonstrates line styles and markers.

#### 2) Plot from a collection of vectors → `line_2.png`

- Builds a `Set` of `Vector{Float64}` values.
- Iterates and calls `plot!` for each vector.
- Demonstrates plotting “container of containers” where each vector becomes a separate series.

#### 3) Sin function line plots with phase shifts → `line_3.png`

- Plots `sin(x)` and phase-shifted versions `sin(x - 0.25)` and `sin(x - 0.5)`.
- Uses different line styles for clarity.

#### 4) Sin function line plots with markers → `line_4.png`

- Similar to (3) but emphasizes marker styles:
  - circles, stars, and different line styles.

#### 5) Simple tiled layout (2×1) → `line_5.png`

- Creates two separate plots (`p_top`, `p_bot`) and combines them with:
  - `plot(p_top, p_bot; layout=(2, 1))`

This is a stacked subplot arrangement in Plots.jl.

#### 6) 3×2 subplots in a single figure → `line_6.png`

Creates a 3×2 grid with six subplots:

- (0,0) `sin(x)` with marker indices using `scatter!`
- (0,1) `tan(sin(x)) - sin(tan(x))` with custom style settings
- (1,0) `cos(5x)` with labels and title
- (1,1) a “time plot” with custom `xticks` labels like `"00:00s"`, `"01:00"`, etc.
- (2,0) `sin(5x)`
- (2,1) a parametric circle with `aspect_ratio=:equal` to avoid distortion

#### 7) Plot from a CSV dataset (download + scatter + line) → `line_csv.png`

- Downloads an Iris dataset CSV from a URL.
- Reads it using `CSV.read(..., DataFrame)`.
- Automatically selects numeric columns and uses the first two numeric columns as x/y.
- Sorts by x so the line overlay is well-behaved.
- Produces a scatter plot with a line overlay.

### Extending the line module

If you add new line examples, keep the structure consistent:

- one `begin ... end` block per figure
- a deterministic output filename (`savefig(..., "line_N.png")`)

</section>

---

<section id="histogram-plots-module-histogramjl">

## Histogram plots module (`histogram.jl`)

This section documents the **histogram** examples implemented in `histogram.jl`.  
It is structured to be modular so you can add future distribution-plot or histogram variants easily.

### Imports and plotting defaults

Key imports:

- `using Plots` — histogram and bar plotting
- `using StatsBase` — histogram utilities such as `countmap`, and statistical helpers
- `using Random, Statistics` — data generation and descriptive stats
- `using CSV, DataFrames, Downloads` — CSV download + reading

Backend selection and defaults:

- `gr()` selects the GR backend.
- `default(...)` sets high-quality global plot parameters:
  - `dpi`, `size`, `framestyle`, `grid`
  - font sizes, line widths, margins, etc.

A helper `saveplot(plt, filename)` wraps `savefig` and prints absolute file paths for convenience.

### Helper functions (core logic)

#### 1) `github_blob_to_raw(url)`

Ensures downloads fetch raw file content rather than HTML pages.

#### 2) `assert_looks_like_csv(path)`

Checks the first bytes of a downloaded file. If the file looks like HTML (e.g., a 404 page), it throws an error immediately.
This prevents confusing downstream CSV parsing errors.

#### 3) `make_edges(x, rule; maxbins=200)`

Builds explicit histogram bin edges using common rules:

- `:sturges` — Sturges’ rule
- `:sqrt` — √n bins
- `:scott` — Scott’s normal reference rule
- `:fd` / `:auto` — Freedman–Diaconis style rule (robust via IQR)
- `:integers` — integer-aligned bins (useful for discrete integer data)

It also includes practical safeguards:

- avoids division-by-zero problems (e.g., zero variance data)
- caps bin count using `maxbins` to prevent pathological over-binning

#### 4) `choose_numeric_column(df)`

A heuristic for selecting a “good” numeric column from a real dataset:

- prefers meaningful column names if present (e.g., `:price`, `:carat`, etc.)
- excludes index-like columns (`id`, `index`, `unnamed`, `row`)
- tries to avoid monotone unique columns (often row IDs)
- otherwise selects the numeric column with the largest variance

### What `histogram.jl` generates

Each block produces an output image file.

#### 1) Simple histogram of standard normal data → `histogram_1.png`

- Generates `randn(10_000)`
- Uses `make_edges(..., :auto)`
- Saves a standard frequency histogram

#### 2) Compare different binning rules → `histogram_2.png`

Creates a 2×3 grid comparing:

- Auto
- Scott
- FD
- Integers
- Sturges
- Sqrt

#### 3) Dynamic bin count demo → `histogram_3.png` (manual bins example saved)

- Demonstrates recomputing edges and updating titles.
- Shows an example with a fixed “50 bins” edge range and saves it.

#### 4) Custom edges + density normalization → `histogram_4.png`

- Provides explicit bin edges
- Uses `normalize=:density` so bar heights represent count density

#### 5) Categorical “histogram” via bar plot → `histogram_5.png`

- Counts string category labels using `countmap`
- Sorts levels
- Plots counts via `bar(...)`

#### 6) Overlay normalized histograms → `histogram_6.png`

- Generates two distributions with different means/sample sizes
- Uses a shared edge vector for meaningful comparison
- Uses `normalize=:probability` so each histogram sums to 1
- Overlays using `histogram!`

#### 7) Histogram as PDF + theoretical normal curve → `histogram_7.png`

- Uses `normalize=:pdf` so the histogram approximates a probability density function
- Defines a normal PDF function and overlays it using `plot!`

#### 8) Histogram from CSV dataset → `histogram_csv.png`

- Downloads a diamonds dataset CSV
- Validates it looks like CSV (not HTML)
- Reads into a DataFrame
- Chooses a numeric column robustly using `choose_numeric_column`
- Builds edges using FD rule with a bin cap (`maxbins=120`)
- Prints dataset summary statistics (n, min, max, mean, std)

### Extending the histogram module

To add new histogram examples, follow the same pattern:

- one `begin ... end` block per figure
- save with deterministic filenames (`histogram_N.png`)
- keep helper functions reusable to avoid duplication

</section>

---

## Implementation tutorial video

At the end of the workflow, you can watch the full implementation and walkthrough on YouTube.

<!--
Replace YOUR_VIDEO_ID with your actual YouTube video ID.
Example URL format: https://www.youtube.com/watch?v=YOUR_VIDEO_ID
Example thumbnail format: https://i.ytimg.com/vi/YOUR_VIDEO_ID/maxresdefault.jpg
-->

<a href="https://www.youtube.com/watch?v=YOUR_VIDEO_ID" target="_blank">
  <img
    src="https://i.ytimg.com/vi/YOUR_VIDEO_ID/maxresdefault.jpg"
    alt="Julia Plotting - Implementation Tutorial"
    style="max-width: 100%; border-radius: 8px; box-shadow: 0 4px 16px rgba(0,0,0,0.15); margin-top: 0.5rem;"
  />
</a>
