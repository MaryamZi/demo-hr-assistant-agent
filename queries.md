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
 
Source: getCompanyCalendarEvents only. No policy retrieval needed. The agent may optionally call getCurrentTime to interpret "next," but this is not required since the calendar returns upcoming events.
 
Expected answer:
The agent should check the company calendar and return the date, time, and any details for the next scheduled town hall. If none is found, it should say so. Example:
 
"The next company town hall is scheduled for [date] at [time]. [Any additional details from the calendar event.]"
 
Note: The exact answer depends on what events are in the calendar. The key thing to verify is that the agent calls getCompanyCalendarEvents and does NOT call retrieveFromPolicies.
 
 
## 3. RAG + Calendar + Time
Query: "I want to take the week leading up to July 4th off. How many PTO days do I actually need?"

Source: getCurrentTime (to establish the current date for date calculations) + getCompanyCalendarEvents (to check which days are company holidays that week) + retrieveFromPolicies / Leave and Time-Off Policy, Section 4 (Paid Holidays)

Expected answer:
The agent should first call getCurrentTime to anchor its date reasoning, then check the calendar to see that Independence Day is observed on July 3 (Friday), and retrieve the holiday policy. It then calculates PTO needs:

"For the week of June 29 - July 3, you'll need to take 4 PTO days. Independence Day is observed on July 3rd (Friday), which is a company holiday, so you only need PTO for Monday through Thursday (June 29 - July 2).

If you have any floating holidays available, you could use one to reduce it to 3 PTO days.

(Leave and Time-Off Policy, Section 4 — Paid Holidays)"

Note: The key thing to verify is that the agent calls all three tools — getCurrentTime, getCompanyCalendarEvents, and retrieveFromPolicies. getCurrentTime should be called first (or in parallel) since the query involves date calculation ("the week leading up to July 4th").
 
 
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