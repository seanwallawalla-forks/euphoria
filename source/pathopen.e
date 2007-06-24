-- (c) Copyright 2007 Rapid Deployment Software - See License.txt
--

atom u32,oem2char,convert_buffer
integer convert_length
constant C_POINTER = #02000004
if platform()=WIN32 then                  
    u32=machine_func(50,"user32.dll")
    oem2char=machine_func(51,{u32,"OemToCharA",{C_POINTER,C_POINTER},C_POINTER})
    convert_length=64
    convert_buffer=allocate(convert_length)
end if

function convert_from_OEM(sequence s)
    integer ls,rc
    
    ls=length(s)
    if ls>convert_length then
        free(convert_buffer)
        convert_length=and_bits(ls+15,-16)+1
        convert_buffer=allocate(convert_length)
    end if
    poke(convert_buffer,s)
    poke(convert_buffer+ls,0)
    rc=c_func(oem2char,{convert_buffer,convert_buffer}) -- always nonzero
    return peek({convert_buffer,ls}) 
end function

constant include_subfolder = SLASH & "include"

sequence cache_vars
cache_vars = {}
sequence cache_strings
cache_strings = {}
sequence cache_substrings
cache_substrings = {}
sequence cache_starts
cache_starts = {}
sequence cache_ends
cache_ends  = {}
sequence cache_converted
if platform()=WIN32 then
    cache_converted = {}
end if
sequence cache_complete
cache_complete = {}
sequence cache_delims
cache_delims = {}
integer num_var

function check_cache(sequence env,sequence inc_path)
    integer delim,pos

    if not num_var then -- first time the vr is accessed, add cache entry
        cache_vars = append(cache_vars,env)
        cache_strings = append(cache_strings,inc_path)
        cache_substrings = append(cache_substrings,{})
        cache_starts = append(cache_starts,{})
        cache_ends = append(cache_ends,{})
        if platform()=WIN32 then
            cache_converted = append(cache_converted,{})
        end if
        num_var = length(cache_vars)
        cache_complete &= 0
        cache_delims &= 0
        return 0
    else
        if compare(inc_path,cache_strings[num_var]) then
            cache_strings[num_var] = inc_path
            cache_complete[num_var] = 0
            if match(cache_strings[num_var],inc_path)!=1 then -- try to salvage what we can
                pos = -1
                for i=1 to length(cache_strings[num_var]) do
                    if cache_ends[num_var][i] > length(inc_path) or 
                      compare(cache_substrings[num_var][i],inc_path[cache_starts[num_var][i]..cache_ends[num_var][i]]) then
                        pos = i-1
                        exit
                    end if
                    if pos = 0 then
                        return 0
                    elsif pos >0 then -- crop cache data
                        cache_substrings[num_var] = cache_substrings[num_var][1..pos]
                        cache_starts[num_var] = cache_starts[num_var][1..pos]
                        cache_ends[num_var] = cache_ends[num_var][1..pos]
                        if platform()=WIN32 then
                            cache_converted[num_var] = cache_converted[num_var][1..pos]
                        end if
                        delim = cache_ends[num_var][$]+1
                        while delim <= length(inc_path) and delim != PATH_SEPARATOR do
                            delim+=1
                        end while
                        cache_delims[num_var] = delim
                    end if
                end for
            end if
        end if
    end if
    return 1
end function

global function ScanPath(sequence file_name,sequence env,integer flag)
-- returns -1 if no path in geenv(env) leads to file_name, else {full_path,handle}
-- if flag is 1, the include_subfolder constant is prepended to filename
    object inc_path
    sequence full_path, file_path, strings
    integer end_path,start_path,try,use_cache, pos

-- Search directories listed on EUINC environment var
    inc_path = getenv(env)
    if compare(inc_path,{})!=1 then -- nothing to do, just fail
        return -1
    end if

    num_var = find(env,cache_vars)
    use_cache = check_cache(env,inc_path)
    inc_path = append(inc_path, PATH_SEPARATOR)

    file_name = SLASH & file_name
    if flag then
        file_name = include_subfolder & file_name
    end if
    strings = cache_substrings[num_var]

    if use_cache then
        for i=1 to length(strings) do
            full_path = strings[i]
            file_path = full_path & file_name
            try = open(file_path, "r")    
            if try != -1 then
                return {file_path,try}
            elsif platform()=WIN32 and sequence(cache_converted[num_var][i]) then
                -- perhaps this path entry, which had never been checked valid, is so after conversion
                full_path = cache_converted[num_var][i]
                file_path = full_path & file_name
                try = open(file_path, "r")
                if try != -1 then
                    cache_converted[num_var][i] = 0
                    cache_substrings[num_var][i] = full_path
                    return {file_path,try}
                end if
            end if
        end for
        if cache_complete[num_var] then -- nothing to scan
            return -1
        else
            pos = cache_delims[num_var]+1 -- scan remainder, starting from as far sa possible
        end if
    else -- scan from scratch
        pos = 1
    end if

    start_path = 0
    for p = pos to length(inc_path) do
	if inc_path[p] = PATH_SEPARATOR then
		    -- end of a directory.
    	    cache_delims[num_var] = p
		    -- remove any trailing blanks and SLASH in directory
    	    end_path = p-1
            while end_path >= start_path and find(inc_path[end_path], " \t" & SLASH_CHARS) do
                end_path-=1
            end while

            if start_path and end_path then
		full_path = inc_path[start_path..end_path]
		cache_substrings[num_var] = append(cache_substrings[num_var],full_path)
		cache_starts[num_var] &= start_path
		cache_ends[num_var] &= end_path
		file_path = full_path & file_name  
		try = open(file_path, "r")
		if try != -1 then -- valid path, no point trying to convert
		    if platform()=WIN32 then  
                        cache_converted[num_var] &= 0
		    end if
                    return {file_path,try}
		elsif platform()=WIN32 then  
                    if find(1,full_path>=128) then
  -- accented characters, try converting them
                        full_path = convert_from_OEM(full_path)
			file_path = full_path & file_name
			try = open(file_path, "r")
			if try != -1 then -- that was it; record translation as the valid path
                            cache_converted[num_var] &= 0
                            cache_substrings[num_var] = append(cache_substrings[num_var],full_path)
                            return {file_path,try}
                        else -- we know we know nothing so far about this path entry
                            cache_converted[num_var] = append(cache_converted[num_var],full_path)
                        end if
                    else -- nothing to convert anyway
                        cache_converted[num_var] &= 0
                    end if
                end if
		start_path = 0
            end if
        elsif not start_path and (inc_path[p] != ' ' and inc_path[p] != '\t') then
            start_path = p
        end if
    end for
    -- everything failed: mark variable as completely read, so as not to scan again if unmodified
    cache_complete[num_var] = 1
    return -1
end function

-- open a file by searching the user's PATH

global function e_path_open(sequence name, sequence mode)
-- follow the search path, if necessary to open the main file
    integer src_file
    object scan_result

    -- try opening directly
    src_file = open(name, mode)
    if src_file != -1 then
	return src_file        
    end if
    
    -- make sure that name is a simple name without '\' in it
    for i = 1 to length(SLASH_CHARS) do
	if find(SLASH_CHARS[i], name) then
	    return -1
	end if
    end for
    
    scan_result = ScanPath(name,"PATH",0)
    if atom(scan_result) then
	return -1
    else
        file_name[1] = scan_result[1]
        return scan_result[2]
    end if
    
end function


