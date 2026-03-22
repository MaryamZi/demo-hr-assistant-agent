# Test Queries — 4 Scenarios with Expected Answers
 
## 1. RAG Only
Query: "What happens if I get 15 attendance points in a year?"
 
Source: Employee Handbook and Code of Conduct, Section 10 (Attendance and Punctuality)
 
Expected answer:
Accumulating 15 points in a rolling 12-month period results in termination. The full disciplinary scale is:
- 6 points: verbal warning (documented)
- 9 points: written warning
- 12 points: final written warning and performance improvement plan
- 15 points: termination
 
Points are tracked on a rolling 12-month basis, so they expire 12 months after each occurrence. Approved leave (PTO, FMLA, etc.) does not generate attendance points.
 
(Employee Handbook, Section 10 — Attendance and Punctuality)
 
 
## 2. Calendar Only
Query: "When's the next company town hall?"
 
Source: getCompanyCalendarEvents only. No policy retrieval needed.
 
Expected answer:
The agent should check the company calendar and return the date, time, and any details for the next scheduled town hall. If none is found, it should say so. Example:
 
"The next company town hall is scheduled for [date] at [time]. [Any additional details from the calendar event.]"
 
Note: The exact answer depends on what events are in the calendar. The key thing to verify is that the agent calls getCompanyCalendarEvents and does NOT call retrieveFromPolicies.
 
 
## 3. RAG + Calendar
Query: "I want to take the week of July 4th off. How many PTO days do I actually need?"
 
Source: getCompanyCalendarEvents (to check which days are company holidays that week) + Leave and Time-Off Policy, Section 4 (Paid Holidays)
 
Expected answer:
The agent should check the calendar to see which days in the July 4th week are already company holidays, then retrieve the holiday and PTO policy to give a complete answer:
 
"Good news — you won't need a full 5 days of PTO. Independence Day (July 3, Friday) is a company holiday, so the office is already closed that day. You'd only need 4 PTO days to cover Monday through Thursday.
 
If you have any floating holidays left, you could use one to bring it down to 3 PTO days.
 
(Leave and Time-Off Policy, Section 4 — Paid Holidays)"
 
 
## 4. General Knowledge (No Tools)
Query: "What's the difference between exempt and non-exempt?"
 
Source: None — general HR knowledge. The agent should NOT call any tools.
 
Expected answer:
"Exempt and non-exempt refer to classifications under the Fair Labor Standards Act (FLSA):
 
- Non-exempt employees are entitled to overtime pay (typically 1.5x their regular rate) for hours worked beyond 40 in a week. They must be paid at least minimum wage and their hours must be tracked.
 
- Exempt employees are not entitled to overtime pay. They're typically salaried and must meet certain criteria around job duties and a minimum salary threshold to qualify.
 
The main practical difference is overtime — if you're non-exempt, you get paid extra for working more than 40 hours. If you're exempt, your salary stays the same regardless of hours worked.
 
If you want to know your specific classification at ConnectWave, I can look that up for you."
 
Key verification: The agent should answer directly without calling retrieveFromPolicies or getCompanyCalendarEvents. If it does call a tool, the "use neither" routing logic needs tuning.