### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 6e792942-8532-43f1-a645-28cfa968b2cf
# ╠═╡ skip_as_script = true
#=╠═╡
begin
	import Pkg
	Pkg.activate(Base.current_project(@__DIR__))
	Pkg.instantiate()
end
  ╠═╡ =#

# ╔═╡ 11410671-d05b-464e-884c-f26283221ce2
begin
    import AbstractPlutoDingetjes
    using HypertextLiteral

    struct Knob
        range::AbstractRange{<:Real}
        show_value::Bool
        default::Real

        function Knob(range::AbstractRange; 
                default::Real=first(range), 
                show_value::Bool=true,
            )
            @assert default >= minimum(range) && default <= maximum(range) "Default value must be within the range."
            new(range, show_value, default)
        end
    end

    function Base.show(io::IO, m::MIME"text/html", k::Knob)
        min_val = minimum(k.range)
        max_val = maximum(k.range)
        step_val = step(k.range)
        default_val = k.default

        show(io, m, @htl("""
        <span class="plutoui-knob-container">
            <style>
                .plutoui-knob-container {
                    display: inline-block;
                    position: relative;
                    width: 140px;
                    height: 140px;
                    font-family: system-ui, -apple-system, sans-serif;
                    user-select: none;
                    touch-action: none;
                    margin: 10px;
                }
                .knob-svg {
                    width: 100%;
                    height: 100%;
                    cursor: grab;
                }
                .knob-svg:active {
                    cursor: grabbing;
                }
                .knob-tick {
                    stroke: #e6e6e6;
                    stroke-width: 0.8;
                    stroke-linecap: round;
                }
                .indicator-group {
                    transform-origin: 50px 50px;
                    transition: transform 0.05s ease-out;
                    will-change: transform;
                }
                .knob-indicator-line {
                    stroke: #0075ff;
                    stroke-width: 4;
                    stroke-linecap: round;
                }
                .knob-value-text {
                    font-size: 1.4rem;
                    font-weight: 500;
                    fill: var(--main-text-color, #333);
                    text-anchor: middle;
                    dominant-baseline: middle;
                    pointer-events: none;
                }
            </style>

            <svg class="knob-svg" viewBox="0 0 100 100">
                <g class="ticks-group"></g>
                <g class="indicator-group">
                    <line x1="50" y1="5" x2="50" y2="18" class="knob-indicator-line" />
                </g>
                $((k.show_value) ? @htl("<text x='50' y='52' class='knob-value-text'></text>") : nothing)
            </svg>

            <script>
            {
                /* Use classes instead of IDs to support multiple Knobs */
                const container = currentScript.parentElement;
                const svg = container.querySelector(".knob-svg");
                const indicatorGroup = container.querySelector(".indicator-group");
                const valueText = container.querySelector(".knob-value-text");
                const ticksGroup = container.querySelector(".ticks-group");

                const min = $(min_val);
                const max = $(max_val);
                const step = $(step_val);
                let currentVal = $(default_val);
                let busy = false;
                
                const svgNS = "http://www.w3.org/2000/svg";

                function valueToDegree(val) {
                    const range = max - min;
                    if (range === 0) return 0;
                    const percent = (val - min) / range;
                    return percent * 360;
                }

                function degreeToValue(deg) {
                    const range = max - min;
                    let normalized = deg / 360;
                    let val = min + normalized * range;
                    
                    if (step > 0) {
                        let steps = Math.round((val - min) / step);
                        val = min + (steps * step);
                    }
                    
                    val = Math.min(Math.max(val, min), max);
                    return val;
                }

                function getAngleFromEvent(e) {
                    const rect = svg.getBoundingClientRect();
                    const cx = rect.left + rect.width / 2;
                    const cy = rect.top + rect.height / 2;
                    const clientX = e.clientX || (e.touches ? e.touches[0].clientX : 0);
                    const clientY = e.clientY || (e.touches ? e.touches[0].clientY : 0);
                    const x = clientX - cx;
                    const y = clientY - cy;

                    let rad = Math.atan2(y, x);
                    let deg = rad * (180 / Math.PI);
                    deg += 90; 
                    if (deg < 0) deg += 360;
                    return deg;
                }

                function updateUI(val) {
                    const deg = valueToDegree(val);
                    indicatorGroup.style.transform = "rotate(" + deg + "deg)";
                    
                    if (valueText) {
                        let textVal = val;
                         if (Number.isInteger(step) && Number.isInteger(min)) {
                            textVal = Math.round(val).toString();
                        } else {
                             const stepString = step.toString();
                             const decimalIndex = stepString.indexOf('.');
                             const decimals = decimalIndex >= 0 ? stepString.length - decimalIndex - 1 : 0;
                             textVal = val.toLocaleString(undefined, {minimumFractionDigits: decimals, maximumFractionDigits: decimals});
                        }
                        valueText.textContent = textVal;
                    }
                }

                const numTicks = 36; 
                for (let i = 0; i < numTicks; i++) {
                    const deg = (i / numTicks) * 360;
                    const line = document.createElementNS(svgNS, "line");
                    line.setAttribute("x1", "50"); line.setAttribute("y1", "5"); 
                    line.setAttribute("x2", "50"); line.setAttribute("y2", "12"); 
                    line.setAttribute("class", "knob-tick");
                    line.setAttribute("transform", "rotate(" + deg + ", 50, 50)");
                    ticksGroup.appendChild(line);
                }

                updateUI(currentVal);

                function handleInput(e) {
                    if (e.type === 'pointermove' && e.pointerType === 'mouse' && e.buttons === 0) {
                        busy = false;
                        return;
                    }

                    const deg = getAngleFromEvent(e);
                    const newVal = degreeToValue(deg);
                    
                    if (newVal !== currentVal) {
                        currentVal = newVal;
                        updateUI(currentVal);
                        container.value = currentVal;
                        /* bubbles: true is REQUIRED for Combine to see the update */
                        container.dispatchEvent(new CustomEvent("input", { bubbles: true, detail: currentVal }));
                    }
                }

                svg.addEventListener("pointerdown", (e) => {
                    busy = true;
                    svg.setPointerCapture(e.pointerId);
                    handleInput(e);
                    e.preventDefault(); 
                });

                svg.addEventListener("pointermove", (e) => {
                    if (!busy) return;
                    handleInput(e);
                    e.preventDefault();
                });

                svg.addEventListener("pointerup", (e) => {
                    busy = false;
                    svg.releasePointerCapture(e.pointerId);
                });
                 svg.addEventListener("pointercancel", (e) => {
                    busy = false;
                    svg.releasePointerCapture(e.pointerId);
                });
                
                Object.defineProperty(container, 'value', {
                    get: () => currentVal,
                    set: (val) => {
                        if (!busy) {
                            currentVal = val;
                            updateUI(val);
                        }
                    }
                });
            }
            </script>
        </span>
        """))
    end

    AbstractPlutoDingetjes.Bonds.initial_value(k::Knob) = k.default

    function closest(range::AbstractRange, x::Real)
        rmin = minimum(range)
        rmax = maximum(range)

        if x <= rmin
            rmin
        elseif x >= rmax
            rmax
        else
            rstep = step(range)
            int_val = (x - rmin) / rstep
            range[round(Int, int_val) + 1]
        end
    end

    function AbstractPlutoDingetjes.Bonds.transform_value(k::Knob, js_val::Any)
        if js_val isa Number
            return closest(k.range, js_val)
        else
            return k.default
        end
    end
end

# ╔═╡ 13f7a5bc-4d8c-49ca-8af5-63165d28ca0a
using PlutoUI

# ╔═╡ eb5185b9-3d70-4096-89a3-3c0caa1a72c7
using PlutoUI: combine

# ╔═╡ e49d941f-a9c8-4403-a08e-ed14e9c44160
@bind angle Knob(0:5:240, default=0)

# ╔═╡ b4fb789c-0ae9-4b0a-ad76-2a94ac5e5b9d
angle

# ╔═╡ 0a01b8a1-4e4b-4429-a7e6-5fa36f864cd7
begin
@bind values PlutoUI.combine() do Child
	md"""
	Knob1 $(
		Child(Knob(0:5:240, default=0))
	) 
	
	Knob2 $(
		Child(Knob(0:5:360, default=0))
	) 

	CheckBox $(Child(CheckBox(true)))
	"""
end
end

# ╔═╡ 9e945096-b0af-497c-b854-9150dfef3a9c
values

# ╔═╡ e78ec4bf-b227-4ec2-9173-ec8deb9abfbf
export Knob

# ╔═╡ Cell order:
# ╠═6e792942-8532-43f1-a645-28cfa968b2cf
# ╠═11410671-d05b-464e-884c-f26283221ce2
# ╠═e49d941f-a9c8-4403-a08e-ed14e9c44160
# ╠═b4fb789c-0ae9-4b0a-ad76-2a94ac5e5b9d
# ╠═13f7a5bc-4d8c-49ca-8af5-63165d28ca0a
# ╠═eb5185b9-3d70-4096-89a3-3c0caa1a72c7
# ╠═0a01b8a1-4e4b-4429-a7e6-5fa36f864cd7
# ╠═9e945096-b0af-497c-b854-9150dfef3a9c
# ╠═e78ec4bf-b227-4ec2-9173-ec8deb9abfbf
