
clear
set obs 5000

// Create unique ID
gen id = _n

// Set parameters
local N = _N
local n = 25


local interval = `= `N' / `n' ' 



// Random start between 1 and interval
set seed 12345
gen u = runiform()
sort u
gen random_start = ceil(runiform() * `interval')
su random_start, meanonly
local start = r(mean)

// Generate selection index using floating interval
gen selected = 0
local cumindex = `start'

// Creating a Loop 

forvalues i = 1/`n' {
    local sel = floor(`cumindex')
    replace selected = 1 if id == `sel'
    local cumindex = `cumindex' + `interval'
}

// Keep only sampled cases
keep if selected == 1
list id
