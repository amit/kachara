#!/usr/bin/env ruby
# This module helps convert the cp1252 encoded characters which are part of 
# some of the evil web pages which wrongly advertize utf8 encoding.
#
# Author: Amit Chakradeo (http://amit.chakradeo.net/)
# Copyright:: Copyright (c) 2009 Amit Chakradeo
# License:: WTFL (http://sam.zoy.org/wtfpl/COPYING)
# 
# This module has a single method kill_gremlins which translates cp1252 
# characters to equivalent utf-8 ones.
#
# Example Usage:
# require 'cp_convert'
# include CP1252
# newtxt = kill_gremlins(oldtxt)
#
#



# Why the lucky stiff - http://redhanded.hobix.com/inspect/closingInOnUnicodeWithJcode.html

$KCODE = 'u'
require 'jcode'

class UString < String
   # Show u-prefix as in Python
   def inspect; "u#{ super }" end

   # Count multibyte characters
   def length; self.scan(/./).length end

   # Reverse the string
   def reverse; self.scan(/./).reverse.join end
 end


 module Kernel
   def u( str )
     UString.new str.gsub(/U\+([0-9a-fA-F]{4,4})/u){["#$1".hex ].pack('U*')}
   end
 end


module CP1252
# Fredrik Lundh - http://effbot.org/zone/unicode-gremlins.htm
cp1252 = {
    # from http=>//www.microsoft.com/typography/unicode/1252.htm
    "\x80"=> "U+20AC", # EURO SIGN
    "\x82"=> "U+201A", # SINGLE LOW-9 QUOTATION MARK
    "\x83"=> "U+0192", # LATIN SMALL LETTER F WITH HOOK
    "\x84"=> "U+201E", # DOUBLE LOW-9 QUOTATION MARK
    "\x85"=> "U+2026", # HORIZONTAL ELLIPSIS
    "\x86"=> "U+2020", # DAGGER
    "\x87"=> "U+2021", # DOUBLE DAGGER
    "\x88"=> "U+02C6", # MODIFIER LETTER CIRCUMFLEX ACCENT
    "\x89"=> "U+2030", # PER MILLE SIGN
    "\x8A"=> "U+0160", # LATIN CAPITAL LETTER S WITH CARON
    "\x8B"=> "U+2039", # SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    "\x8C"=> "U+0152", # LATIN CAPITAL LIGATURE OE
    "\x8E"=> "U+017D", # LATIN CAPITAL LETTER Z WITH CARON
    "\x91"=> "U+2018", # LEFT SINGLE QUOTATION MARK
    "\x92"=> "U+2019", # RIGHT SINGLE QUOTATION MARK
    "\x93"=> "U+201C", # LEFT DOUBLE QUOTATION MARK
    "\x94"=> "U+201D", # RIGHT DOUBLE QUOTATION MARK
    "\x95"=> "U+2022", # BULLET
    "\x96"=> "U+2013", # EN DASH
    "\x97"=> "U+2014", # EM DASH
    "\x98"=> "U+02DC", # SMALL TILDE
    "\x99"=> "U+2122", # TRADE MARK SIGN
    "\x9A"=> "U+0161", # LATIN SMALL LETTER S WITH CARON
    "\x9B"=> "U+203A", # SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    "\x9C"=> "U+0153", # LATIN SMALL LIGATURE OE
    "\x9E"=> "U+017E", # LATIN SMALL LETTER Z WITH CARON
    "\x9F"=> "U+0178", # LATIN CAPITAL LETTER Y WITH DIAERESIS
}

# http://garbageburrito.com/blog/entry/88/converting-cp1252-to-utf8-with-rubyrails
CP1252 = cp1252.keys.join
UTF = cp1252.values.join

def kill_gremlins(text)
    return text.tr(CP1252,u(UTF))
end
end


