# Innovation Features

## Emergency Broadcast and Reach Analytics

Administrators can assign Normal, Important, or Urgent priority; target an RHU and barangay; schedule publication and expiration; attach an image or document; and review recipient, read, and reach percentage metrics. A patient read is counted only when that announcement is actually displayed in the dashboard spotlight.

## Barangay Disease Early-Warning

The Disease Trends page compares cases from the latest seven days with the weekly average of the previous four weeks. High and watch rules are shown only as aggregated barangay totals. Patient identities are never returned by the warning endpoint.

## QR Arrival and Queue Alert

Each patient QR is a random one-time pass. Only its SHA-256 hash is stored. Staff can use the camera scanner or manual fallback, and the server verifies expiry, appointment date, one-time use, and RHU assignment. Queue changes create a patient notification when three or fewer people remain ahead.

Camera and browser notifications require HTTPS after deployment. Localhost is accepted for development.

## Family and Caregiver Access

A caregiver sends a request using the dependent's email or patient ID. The dependent must approve before the caregiver can view or create dependent appointments. Either account can revoke access. Every appointment remains attached to the dependent's separate patient record.

## Offline and Low-Data Mode

The patient portal is installable as a PWA. It caches the application shell and locally saves the most recent appointment, queue snapshot, and unexpired QR pass on that device. Offline mode is read-only: booking, cancellation, consent, check-in, and other writes are blocked until connectivity returns. Cached private data is cleared on logout.

## Help Center Automatic Reply

Every patient inquiry is routed to the selected RHU and receives an immediate, clearly labeled automated reply. The rule-based guidance covers appointments, queue concerns, QR arrival, requirements, immunization, clinic schedules, and private records. Emergency keywords show a call-911/nearest-emergency-facility warning. Automated messages never mark the patient's inquiry as handled: assigned staff still see the original concern as unread and can reply in the same thread with their own name.
