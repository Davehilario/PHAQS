USE health_center_system;

-- otp handling
UPDATE admins
SET email='pulilanhealthcenteradmin@gmail.com',
    name='System Administrator',
    role='System Administrator',
    branch='All Branches'
WHERE email='admin@pulilan.gov.ph'
   OR (role='System Administrator' AND branch='All Branches');

DELETE FROM admins
WHERE email IN (
  'ashleyamira955@gmail.com',
  'ashleyamira955+rhu1@gmail.com',
  'ashleyamira955+rhu2@gmail.com',
  'ashleyamira955+rhu3@gmail.com',
  'ashleyamira955+rhu4@gmail.com',
  'admin@healthcenter.local'
);

UPDATE admins SET name='RHU I Staff', role='RHU Staff', branch='RHU I - Poblacion'
WHERE email='rhu1@pulilan.gov.ph';

UPDATE admins SET name='RHU II Staff', role='RHU Staff', branch='RHU II - Cutcot'
WHERE email='rhu2@pulilan.gov.ph';

UPDATE admins SET name='RHU III Staff', role='RHU Staff', branch='RHU III - Tinejero'
WHERE email='rhu3@pulilan.gov.ph';

UPDATE admins SET name='RHU IV Staff', role='RHU Staff', branch='RHU IV - Tibag'
WHERE email='rhu4@pulilan.gov.ph';
