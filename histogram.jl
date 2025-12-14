# histogram.jl
#
# Requirements (run once in the Julia REPL):
#   import Pkg
#   Pkg.add(["Plots", "StatsBase", "CSV", "DataFrames"])

using Random
using Statistics
using StatsBase
using Plots

using CSV
using DataFrames
using Downloads

# ----------------------------
# High-quality plot defaults
# ----------------------------
gr()

const DPI       = 300
const SIZE_STD  = (1600, 1000)
const SIZE_WIDE = (2600, 1500)

default(
    dpi = DPI,
    size = SIZE_STD,
    framestyle = :box,
    grid = true,
    titlefontsize = 18,
    guidefontsize = 14,
    tickfontsize  = 12,
    legendfontsize = 12,
    linewidth = 2,
    margin = 6Plots.mm,
)

Random.seed!(42)

# Helper: convert GitHub "blob" links to "raw" links
function github_blob_to_raw(url::AbstractString)::String
    if occursin("github.com", url) && occursin("/blob/", url)
        url2 = replace(url, "https://github.com/" => "https://raw.githubusercontent.com/")
        url2 = replace(url2, "/blob/" => "/")
        return url2
    end
    return url
end

# Sanity check: if a download returns HTML (404 page, etc.), fail fast.
function assert_looks_like_csv(path::AbstractString; nbytes::Int=800)
    bytes = read(path, min(nbytes, filesize(path)))
    head = lowercase(String(bytes))
    if occursin("<html", head) || occursin("<!doctype", head) || occursin("not found", head)
        error("Downloaded file does not look like a CSV (it looks like HTML / an error page). Check the CSV URL.")
    end
    return nothing
end

# Build explicit histogram edges using common binning rules.
# Adds maxbins to avoid pathological over-binning for wide-span data.
function make_edges(x::AbstractVector{<:Real}, rule::Symbol; maxbins::Int=200)::Vector{Float64}
    xclean = collect(skipmissing(x))
    n = length(xclean)
    @assert n > 1 "Need at least two observations."

    xmin, xmax = extrema(xclean)
    span = xmax - xmin
    if span == 0
        return [float(xmin - 0.5), float(xmax + 0.5)]
    end

    if rule == :integers
        xi = round.(Int, xclean)
        lo = minimum(xi) - 0.5
        hi = maximum(xi) + 0.5
        edges = collect(range(float(lo), float(hi); step=1.0))
        return length(edges) >= 2 ? edges : [float(lo), float(hi)]
    end

    k = if rule == :sturges
        ceil(Int, 1 + log2(n))
    elseif rule == :sqrt
        ceil(Int, sqrt(n))
    elseif rule == :scott
        σ = std(xclean)
        w = 3.5 * σ * n^(-1/3)
        (w == 0) ? ceil(Int, sqrt(n)) : max(1, ceil(Int, span / w))
    elseif rule == :fd || rule == :auto
        iqr = quantile(xclean, 0.75) - quantile(xclean, 0.25)
        w = 2 * iqr * n^(-1/3)
        (w == 0) ? ceil(Int, sqrt(n)) : max(1, ceil(Int, span / w))
    else
        error("Unsupported rule: $rule")
    end

    k = max(1, min(k, maxbins))
    return collect(range(float(xmin), float(xmax); length=k + 1))
end

# Heuristic: choose a "good" numeric column for histogramming.
# Preference order: price, carat, depth, table, x, y, z (if present),
# otherwise pick a non-index-looking numeric column with the largest variance.
function choose_numeric_column(df::DataFrame)::Symbol
    numeric_cols = Symbol[]

    # IMPORTANT FIX: names(df) are Strings here; convert to Symbol before pushing.
    for cname in names(df)
        c = Symbol(cname)
        T = Base.nonmissingtype(eltype(df[!, c]))
        if T <: Real
            push!(numeric_cols, c)
        end
    end
    @assert !isempty(numeric_cols) "CSV must contain at least one numeric column."

    preferred = [:price, :carat, :depth, :table, :x, :y, :z]
    for p in preferred
        if p in numeric_cols
            return p
        end
    end

    function name_looks_like_index(c::Symbol)::Bool
        s = lowercase(String(c))
        return occursin("id", s) || occursin("index", s) || occursin("unnamed", s) || occursin("row", s)
    end

    function looks_monotone_unique(v)::Bool
        x = collect(skipmissing(v))
        n = length(x)
        n < 5 && return true
        ur = length(unique(x)) / n
        if ur < 0.95
            return false
        end
        d = diff(x)
        return all(≥(0), d) || all(≤(0), d)
    end

    candidates = Symbol[]
    for c in numeric_cols
        v = df[!, c]
        if name_looks_like_index(c)
            continue
        end
        if looks_monotone_unique(v)
            continue
        end
        push!(candidates, c)
    end

    if isempty(candidates)
        return numeric_cols[1]
    end

    best_col = candidates[1]
    best_var = -Inf
    for c in candidates
        x = collect(skipmissing(df[!, c]))
        v = var(x)
        if isfinite(v) && v > best_var
            best_var = v
            best_col = c
        end
    end
    return best_col
end

saveplot(plt, filename::AbstractString) = (savefig(plt, filename); println("Saved: ", abspath(filename)))

# ---------------------------------------------------------
# 1) Simple histogram of standard normal data (auto bins)
# ---------------------------------------------------------
begin
    x1 = randn(10_000)
    edges1 = make_edges(x1, :auto)
    nbins1 = length(edges1) - 1

    p1 = histogram(
        x1;
        bins=edges1,
        label=false,
        xlabel="Value",
        ylabel="Frequency",
        title="Histogram of standard normal data ($nbins1 bins)",
        dpi=DPI,
        size=SIZE_STD,
    )

    saveplot(p1, "histogram_1.png")
end

# ---------------------------------------------------------
# 2) Compare different binning rules
# ---------------------------------------------------------
begin
    x2 = randn(10_000)

    p_auto    = histogram(x2; bins=make_edges(x2, :auto),     label=false, xlabel="Value", ylabel="Frequency", title="Auto",     dpi=DPI)
    p_scott   = histogram(x2; bins=make_edges(x2, :scott),    label=false, xlabel="Value", ylabel="Frequency", title="Scott",    dpi=DPI)
    p_fd      = histogram(x2; bins=make_edges(x2, :fd),       label=false, xlabel="Value", ylabel="Frequency", title="FD",       dpi=DPI)
    p_int     = histogram(x2; bins=make_edges(x2, :integers), label=false, xlabel="Value", ylabel="Frequency", title="Integers", dpi=DPI)
    p_sturges = histogram(x2; bins=make_edges(x2, :sturges),  label=false, xlabel="Value", ylabel="Frequency", title="Sturges",  dpi=DPI)
    p_sqrt    = histogram(x2; bins=make_edges(x2, :sqrt),     label=false, xlabel="Value", ylabel="Frequency", title="Sqrt",     dpi=DPI)

    p2 = plot(p_auto, p_scott, p_fd, p_int, p_sturges, p_sqrt; layout=(2, 3), size=SIZE_WIDE, dpi=DPI)
    saveplot(p2, "histogram_2.png")
end

# ---------------------------------------------------------
# 3) Dynamic bin count demo
# ---------------------------------------------------------
begin
    x3 = randn(1_000)

    edges_auto = make_edges(x3, :auto)
    nbins_auto = length(edges_auto) - 1

    p3 = histogram(
        x3;
        bins=edges_auto,
        label=false,
        xlabel="Value",
        ylabel="Frequency",
        title="$(nbins_auto) bins (auto)",
        dpi=DPI,
        size=SIZE_STD,
    )
    display(p3)

    for _ in 1:5
        sleep(1)
        title!(p3, "$(nbins_auto) bins (auto)")
    end

    xmin, xmax = extrema(x3)
    edges_50 = collect(range(float(xmin), float(xmax); length=51))

    p3b = histogram(
        x3;
        bins=edges_50,
        label=false,
        xlabel="Value",
        ylabel="Frequency",
        title="50 bins (manual)",
        dpi=DPI,
        size=SIZE_STD,
    )

    saveplot(p3b, "histogram_3.png")
end

# ---------------------------------------------------------
# 4) Custom edges + density normalization
# ---------------------------------------------------------
begin
    x4 = randn(10_000)

    edges = [
        -10.0000, -2.0000, -1.7500, -1.5000, -1.2500,
        -1.0000,  -0.7500, -0.5000, -0.2500,  0.0000,
         0.2500,   0.5000,  0.7500,  1.0000,  1.2500,
         1.5000,   1.7500,  2.0000, 10.0000,
    ]

    p4 = histogram(
        x4;
        bins=edges,
        normalize=:density,
        label=false,
        xlabel="Value",
        ylabel="Count density",
        title="Histogram with custom bin edges (density)",
        dpi=DPI,
        size=SIZE_WIDE,
    )

    saveplot(p4, "histogram_4.png")
end

# ---------------------------------------------------------
# 5) Categorical histogram
# ---------------------------------------------------------
begin
    categories = [
        "no", "no", "yes", "yes", "yes", "no", "no",
        "no", "no", "undecided", "undecided", "yes", "no", "no",
        "no", "yes", "no", "yes", "no", "yes", "no",
        "no", "no", "yes", "yes", "yes", "yes",
    ]

    counts = countmap(categories)
    levels = sort(collect(keys(counts)))
    values = [counts[k] for k in levels]

    p5 = bar(
        levels, values;
        legend=false,
        xlabel="Category",
        ylabel="Count",
        title="Histogram of categorical responses",
        size=SIZE_WIDE,
        dpi=DPI,
        bar_width=0.5,
    )

    saveplot(p5, "histogram_5.png")
end

# ---------------------------------------------------------
# 6) Overlay normalized histograms
# ---------------------------------------------------------
begin
    x5 = randn(2_000)
    y5 = 1 .+ randn(5_000)

    edges = collect(-5.0:0.25:6.0)

    p6 = histogram(
        x5;
        bins=edges,
        normalize=:probability,
        xlabel="Value",
        ylabel="Probability",
        title="Overlaid normalized histograms",
        label="Dist A",
        dpi=DPI,
        size=SIZE_STD,
    )
    histogram!(p6, y5; bins=edges, normalize=:probability, label="Dist B")

    saveplot(p6, "histogram_6.png")
end

# ---------------------------------------------------------
# 7) Histogram as PDF + theoretical normal curve
# ---------------------------------------------------------
begin
    mu = 5.0
    sigma = 2.0
    x6 = mu .+ sigma .* randn(5_000)

    edges = collect(range(-5.0, 15.0; length=81))

    p7 = histogram(
        x6;
        bins=edges,
        normalize=:pdf,
        xlabel="Value",
        ylabel="Probability density",
        title="Histogram with theoretical normal PDF",
        label="Empirical",
        dpi=DPI,
        size=SIZE_STD,
    )

    normal_pdf(t) = exp(-((t - mu)^2) / (2 * sigma^2)) / (sigma * sqrt(2π))
    plot!(p7, normal_pdf, -5.0, 15.0; label="Theoretical PDF", linewidth=3)

    saveplot(p7, "histogram_7.png")
end

# ---------------------------------------------------------
# 8) Histogram from CSV dataset (FIXED selection logic)
# ---------------------------------------------------------
begin
    csv_url = "https://raw.githubusercontent.com/mohammadijoo/Datasets/refs/heads/main/diamonds.csv"
    csv_url = github_blob_to_raw(csv_url)

    local_file = Downloads.download(csv_url)
    assert_looks_like_csv(local_file)

    df = CSV.read(local_file, DataFrame)

    # Use invokelatest to avoid Julia 1.12 world-age issues in VSCode debug/revise workflows.
    col = Base.invokelatest(choose_numeric_column, df)

    data = collect(skipmissing(df[!, col]))

    println("CSV histogram column chosen: ", col)
    println("  n = ", length(data),
            ", min = ", minimum(data),
            ", max = ", maximum(data),
            ", mean = ", mean(data),
            ", std = ", std(data))

    # FD binning with a cap prevents over-fragmentation on wide-span columns.
    edges_csv = make_edges(data, :fd; maxbins=120)

    p_csv = histogram(
        data;
        bins=edges_csv,
        label=false,
        xlabel=String(col),
        ylabel="Frequency",
        title="Histogram from CSV dataset ($(col))",
        dpi=DPI,
        size=SIZE_STD,
    )

    saveplot(p_csv, "histogram_csv.png")
end
