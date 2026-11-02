# CM QA Test Cases — August 2026 Update

Use a test database or disposable test accounts for the checks below. The expected result must happen before the next test is marked as passed.

| ID | Area | Steps | Expected result |
| --- | --- | --- | --- |
| QA-01 | Announcements | Open **New Announcement**, enter text, then select **Cancel**, the close `×`, and press `Esc` in separate tests. | The editor closes immediately, clears the unsaved draft, and the announcement list is usable again. |
| QA-02 | Reports apply control | Change date range or RHU without selecting **Apply**. Then select **Apply**. | Cards, table, and charts remain unchanged until **Apply**; all update together after **Apply**. |
| QA-03 | Reports CSV/Excel/PDF | Select a report filter, select **Apply**, then export CSV, Excel, and **Save as PDF**. | Each file reflects the applied filter. **Save as PDF** downloads a PDF and does not open the browser print dialog. |
| QA-04 | Print report | Select **Print Report** and inspect print preview. | Only the printable report appears. Sidebar, top navigation, filters, action buttons, notification UI, and Help Chat are not printed. |
| QA-05 | Heatmap CSV | In **Heatmap & Analytics**, select **Export CSV**, then open the downloaded file in Excel/WPS. | Headers and case records appear in separate rows and columns; commas inside a cell do not split the record incorrectly. |
| QA-06 | Heatmap edit | Select **Edit** for a disease case, change one allowed value, save, then return to analytics. | The real edit form opens with the selected record; the saved change is shown after return. |
| QA-07 | Accessibility/responsiveness | Repeat QA-01 through QA-06 at desktop, tablet, and phone widths. | Buttons remain visible, reachable, and have a single action; no modal or menu traps the user. |
| QA-08 | Regression smoke test | Sign in as admin, staff, and patient. Navigate their primary menu items and return to dashboards. | Correct role restrictions remain active and no navigation link leads to a missing local page. |

## Notes for testing

- Use **Print Report** only when a physical/browser print preview is intended.
- Use **Save as PDF** when a file download is intended.
- If the browser keeps an older JavaScript file after replacing the project folder, perform a hard refresh (`Ctrl + F5`) once before retesting.
- Do not test destructive actions on production records without a backup.
