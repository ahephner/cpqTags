list<string> pb = new list<string>(); 
pb.add('01s75000000PxUCAA0');
pb.add('01s75000000PxcVAAS');
pb.add('01s75000000PxcGAAS');
pb.add('01sO3000000KvYPIA0');
pb.add('01s75000000PygnAAC');
pb.add('01sO3000000KvdFIAS');
pb.add('01s75000000PykbAAC');
pb.add('01s75000000PxUCAA0');
pb.add('01sO30000002y05IAA');
list<PricebookEntry> best = [select Pricebook2.Name, id, unitprice from PricebookEntry where Pricebook2Id in: (pb) and Product2ID= '01t75000000Yt2BAAS' ORDER BY UnitPrice ASC limit 1];

system.debug(best);