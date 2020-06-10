/*
Copyright 2020 Brightworks, Inc.

This file is part of Language Mentor.

Language Mentor is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Language Mentor is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Language Mentor.  If not, see <http://www.gnu.org/licenses/>.


ITechReport defines no functions - its role is purely semantic.

Subclasses should be designed to work with, i.e. serve as a report for, one specific
class, and their names should consist of that class's name, plus "TechReport" (preferred?),
"ResultsReport", "SuccessReport", or "ErrorReport". For example, "FooTechReport".

These report class should report technical details so that, if its state is printed
to console etc. it will describe the state of the dispatching class in a technically
useful way. This info should not be designed for consumption by users, but may be
parsed by client code and used in the creation of user-friendly messages.


*/
package com.brightworks.techreport {

public interface ITechReport {
   function dispose():void
}

}

