include std/unittest.e
include std/os.e

ifdef hello then
    test_fail("not defined #1")
end ifdef

with define hello_
ifdef hello_ then
    test_pass("defined #1")
elsedef
    test_fail("defined #1")
end ifdef

without define hello_
ifdef hello then
    test_fail("undefine #1")
end ifdef

ifdef UNIX then
    if platform() >= 3 then
		test_pass("UNIX test")
	else
		test_fail("UNIX test")
	end if
end ifdef

ifdef SUNOS then
	test_equal("SunOS test", 5, platform())
end ifdef

ifdef OSX then
    test_equal("OSX test", 4, platform())
end ifdef

ifdef FREEBSD then
	test_equal("FREEBSD test", 8, platform())
end ifdef

ifdef LINUX then
	test_equal("LINUX test", 3, platform())
end ifdef

ifdef WIN32 then
	test_equal("WIN32 test", 2, platform())
end ifdef

ifdef EU4_0_0 then
    test_pass("EU4_0_0")
elsedef
    test_fail("EU4_0_0")
end ifdef

ifdef EU4_0 then
	test_pass("EU4_0")
elsedef
	test_fail("EU4_0")
end ifdef

ifdef EU4 then
	test_pass("EU4")
elsedef
	test_fail("EU4")
end ifdef

test_report()
