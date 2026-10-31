BEGIN TRANSACTION;
CREATE TABLE audit_logs (
	id INTEGER NOT NULL, 
	actor_id INTEGER, 
	action VARCHAR(60) NOT NULL, 
	entity VARCHAR(40) NOT NULL, 
	entity_id VARCHAR(40) NOT NULL, 
	detail TEXT NOT NULL, 
	ip_address VARCHAR(64) NOT NULL, 
	timestamp DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(actor_id) REFERENCES users (id) ON DELETE SET NULL
);
INSERT INTO "audit_logs" VALUES(1,1,'system.seed','database','','Seeded 60 articles, 21 users, 128 comments','','2026-10-31 07:12:41.379882');
INSERT INTO "audit_logs" VALUES(2,NULL,'auth.login_failed','user','','login=voduchuy','127.0.0.1','2026-10-31 07:23:49.667298');
INSERT INTO "audit_logs" VALUES(3,22,'auth.register','user','22','','127.0.0.1','2026-10-31 07:24:02.303609');
INSERT INTO "audit_logs" VALUES(4,22,'auth.login','user','22','','127.0.0.1','2026-10-31 07:24:12.714046');
INSERT INTO "audit_logs" VALUES(5,22,'auth.login','user','22','','127.0.0.1','2026-10-31 08:08:44.895058');
CREATE TABLE categories (
	id INTEGER NOT NULL, 
	name VARCHAR(80) NOT NULL, 
	slug VARCHAR(90) NOT NULL, 
	description VARCHAR(500) NOT NULL, 
	color VARCHAR(9) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
INSERT INTO "categories" VALUES(1,'Technology','technology','Software, security, devices and the internet, explained clearly.','#3157D5');
INSERT INTO "categories" VALUES(2,'Science','science','Physics, biology, space and how research works.','#7A3FC4');
INSERT INTO "categories" VALUES(3,'Health','health','Evidence-based explainers on sleep, nutrition, exercise and medicine.','#0F8A6A');
INSERT INTO "categories" VALUES(4,'Environment','environment','Climate, energy, oceans, wildlife and resources.','#4C8A1E');
INSERT INTO "categories" VALUES(5,'Business & Money','business-money','Personal finance, the economy, startups and careers.','#C2571A');
INSERT INTO "categories" VALUES(6,'Education','education','How we learn, study and choose what to study.','#B3366B');
CREATE TABLE comment_mentions (
	comment_id INTEGER NOT NULL, 
	mentioned_user_id INTEGER NOT NULL, 
	PRIMARY KEY (comment_id, mentioned_user_id), 
	FOREIGN KEY(comment_id) REFERENCES comments (id) ON DELETE CASCADE, 
	FOREIGN KEY(mentioned_user_id) REFERENCES users (id) ON DELETE CASCADE
);
INSERT INTO "comment_mentions" VALUES(7,12);
INSERT INTO "comment_mentions" VALUES(16,15);
INSERT INTO "comment_mentions" VALUES(23,17);
INSERT INTO "comment_mentions" VALUES(26,14);
INSERT INTO "comment_mentions" VALUES(32,20);
INSERT INTO "comment_mentions" VALUES(37,13);
INSERT INTO "comment_mentions" VALUES(41,15);
INSERT INTO "comment_mentions" VALUES(47,16);
INSERT INTO "comment_mentions" VALUES(54,11);
INSERT INTO "comment_mentions" VALUES(57,19);
INSERT INTO "comment_mentions" VALUES(61,4);
INSERT INTO "comment_mentions" VALUES(65,21);
INSERT INTO "comment_mentions" VALUES(76,14);
INSERT INTO "comment_mentions" VALUES(83,11);
INSERT INTO "comment_mentions" VALUES(90,3);
INSERT INTO "comment_mentions" VALUES(94,12);
INSERT INTO "comment_mentions" VALUES(105,3);
INSERT INTO "comment_mentions" VALUES(108,14);
INSERT INTO "comment_mentions" VALUES(111,21);
INSERT INTO "comment_mentions" VALUES(115,17);
INSERT INTO "comment_mentions" VALUES(128,20);
CREATE TABLE comments (
	id INTEGER NOT NULL, 
	document_id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	parent_id INTEGER, 
	content TEXT NOT NULL, 
	status VARCHAR(20) NOT NULL, 
	flag_reason VARCHAR(255) NOT NULL, 
	created_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(document_id) REFERENCES documents (id) ON DELETE CASCADE, 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	FOREIGN KEY(parent_id) REFERENCES comments (id) ON DELETE CASCADE
);
INSERT INTO "comments" VALUES(1,17,12,NULL,'Bookmarking this for our team onboarding.','visible','','2026-06-22 17:12:40.563957');
INSERT INTO "comments" VALUES(2,17,17,NULL,'This finally made it click for me, thanks.','visible','','2026-07-07 00:12:40.563957');
INSERT INTO "comments" VALUES(3,17,5,NULL,'Shared this with my parents. Very clear.','visible','','2026-07-05 17:12:40.563957');
INSERT INTO "comments" VALUES(4,17,20,NULL,'I switched to an authenticator app last year and never looked back.','visible','','2026-06-29 15:12:40.563957');
INSERT INTO "comments" VALUES(5,21,12,NULL,'The practical tips at the end are the best part.','visible','','2026-07-16 22:12:40.563957');
INSERT INTO "comments" VALUES(6,21,10,NULL,'Clear, calm and not preachy. Thank you.','visible','','2026-07-03 11:12:40.563957');
INSERT INTO "comments" VALUES(7,21,14,5,'Good point @chi_nguyen, I had the same question.','visible','','2026-07-17 21:12:40.563957');
INSERT INTO "comments" VALUES(8,42,16,NULL,'Clear explanation, I sent it to my younger brother.','visible','','2026-09-20 07:12:40.563957');
INSERT INTO "comments" VALUES(9,42,11,NULL,'Would love a piece on how pensions work next.','visible','','2026-09-18 20:12:40.563957');
INSERT INTO "comments" VALUES(10,42,15,NULL,'Wish I had read this in my twenties.','visible','','2026-09-07 18:12:40.563957');
INSERT INTO "comments" VALUES(11,42,21,NULL,'The rule of 72 trick is great.','visible','','2026-09-11 17:12:40.563957');
INSERT INTO "comments" VALUES(12,13,10,NULL,'Balanced article, thanks for not overselling it.','visible','','2026-06-16 21:12:40.563957');
INSERT INTO "comments" VALUES(13,54,15,NULL,'Clear and accurate, which is rare for this topic.','visible','','2026-10-26 09:12:40.563957');
INSERT INTO "comments" VALUES(14,54,13,NULL,'Great explanation without dumbing it down.','visible','','2026-10-25 05:12:40.563957');
INSERT INTO "comments" VALUES(15,54,18,NULL,'The diagram in my head finally makes sense now.','visible','','2026-10-21 21:12:40.563957');
INSERT INTO "comments" VALUES(16,54,12,13,'@farah_n totally agree with you.','visible','','2026-10-27 05:12:40.563957');
INSERT INTO "comments" VALUES(17,56,4,NULL,'Would be great to have a reading list at the end.','visible','','2026-10-17 09:12:40.563957');
INSERT INTO "comments" VALUES(18,56,10,NULL,'Great explanation without dumbing it down.','visible','','2026-10-24 11:12:40.563957');
INSERT INTO "comments" VALUES(19,56,14,NULL,'The diagram in my head finally makes sense now.','visible','','2026-10-26 05:12:40.563957');
INSERT INTO "comments" VALUES(20,44,17,NULL,'Would love a follow-up on how this works for small companies.','visible','','2026-09-25 04:12:40.563957');
INSERT INTO "comments" VALUES(21,44,21,NULL,'I switched to an authenticator app last year and never looked back.','visible','','2026-09-14 09:12:40.563957');
INSERT INTO "comments" VALUES(22,44,11,NULL,'This finally made it click for me, thanks.','visible','','2026-09-17 04:12:40.563957');
INSERT INTO "comments" VALUES(23,44,10,20,'Thanks @huong_le, that is helpful.','visible','','2026-09-26 04:12:40.563957');
INSERT INTO "comments" VALUES(24,43,14,NULL,'As a teacher, I agree with every point here.','visible','','2026-09-14 07:12:40.563957');
INSERT INTO "comments" VALUES(25,43,4,NULL,'Our teachers started doing low-stakes quizzes and it helps.','visible','','2026-09-12 11:12:40.563957');
INSERT INTO "comments" VALUES(26,43,16,24,'@elif_y there is a related article in this category too.','visible','','2026-09-14 09:12:40.563957');
INSERT INTO "comments" VALUES(27,57,14,NULL,'Very practical. Setting up an automatic transfer today.','visible','','2026-10-28 22:12:40.563957');
INSERT INTO "comments" VALUES(28,40,20,NULL,'Sharing this with my study group.','visible','','2026-09-08 21:12:40.563957');
INSERT INTO "comments" VALUES(29,40,19,NULL,'As a teacher, I agree with every point here.','visible','','2026-09-08 21:12:40.563957');
INSERT INTO "comments" VALUES(30,40,4,NULL,'Retrieval practice changed how I study.','visible','','2026-09-03 18:12:40.563957');
INSERT INTO "comments" VALUES(31,40,16,NULL,'Our teachers started doing low-stakes quizzes and it helps.','visible','','2026-09-10 18:12:40.563957');
INSERT INTO "comments" VALUES(32,40,19,28,'@kenji_t totally agree with you.','visible','','2026-09-09 04:12:40.563957');
INSERT INTO "comments" VALUES(33,39,13,NULL,'Our city just started a tree planting programme, this explains why.','visible','','2026-08-27 21:12:40.563957');
INSERT INTO "comments" VALUES(34,39,10,NULL,'Balanced article, thanks for not overselling it.','visible','','2026-08-29 18:12:40.563957');
INSERT INTO "comments" VALUES(35,39,13,NULL,'Rinsing containers really does matter, our local plant says so too.','visible','','2026-08-28 15:12:40.563957');
INSERT INTO "comments" VALUES(36,39,20,NULL,'Would like to see numbers for different countries.','visible','','2026-08-29 09:12:40.563957');
INSERT INTO "comments" VALUES(37,39,4,33,'Good point @david_m, I had the same question.','visible','','2026-08-28 14:12:40.563957');
INSERT INTO "comments" VALUES(38,60,15,NULL,'Very practical. Setting up an automatic transfer today.','visible','','2026-11-11 14:12:40.563957');
INSERT INTO "comments" VALUES(39,7,15,NULL,'Lateral reading is such a useful habit.','visible','','2026-05-31 12:12:40.563957');
INSERT INTO "comments" VALUES(40,7,20,NULL,'The Cornell method works really well for my lectures.','visible','','2026-06-04 19:12:40.563957');
INSERT INTO "comments" VALUES(41,7,12,39,'@farah_n totally agree with you.','visible','','2026-05-31 13:12:40.563957');
INSERT INTO "comments" VALUES(42,30,15,NULL,'Sharing this with my study group.','visible','','2026-08-11 13:12:40.563957');
INSERT INTO "comments" VALUES(43,30,14,NULL,'The Cornell method works really well for my lectures.','visible','','2026-08-13 04:12:40.563957');
INSERT INTO "comments" VALUES(44,37,16,NULL,'Rinsing containers really does matter, our local plant says so too.','visible','','2026-08-26 04:12:40.563957');
INSERT INTO "comments" VALUES(45,37,18,NULL,'Would like to see numbers for different countries.','visible','','2026-08-22 12:12:40.563957');
INSERT INTO "comments" VALUES(46,37,4,NULL,'Balanced article, thanks for not overselling it.','visible','','2026-08-26 05:12:40.563957');
INSERT INTO "comments" VALUES(47,37,13,44,'Good point @gabe_r, I had the same question.','visible','','2026-08-26 20:12:40.563957');
INSERT INTO "comments" VALUES(48,35,14,NULL,'Very practical. Setting up an automatic transfer today.','visible','','2026-08-19 22:12:40.563957');
INSERT INTO "comments" VALUES(49,35,16,NULL,'Wish I had read this in my twenties.','visible','','2026-08-17 10:12:40.563957');
INSERT INTO "comments" VALUES(50,35,18,NULL,'The rule of 72 trick is great.','visible','','2026-08-17 07:12:40.563957');
INSERT INTO "comments" VALUES(51,16,11,NULL,'The rule of 72 trick is great.','visible','','2026-06-22 14:12:40.563957');
INSERT INTO "comments" VALUES(52,16,10,NULL,'Would love a piece on how pensions work next.','visible','','2026-06-18 10:12:40.563957');
INSERT INTO "comments" VALUES(53,16,14,NULL,'Clear explanation, I sent it to my younger brother.','visible','','2026-06-29 19:12:40.563957');
INSERT INTO "comments" VALUES(54,16,14,51,'@ben_carter there is a related article in this category too.','visible','','2026-06-22 20:12:40.563957');
INSERT INTO "comments" VALUES(55,41,19,NULL,'Clear and accurate, which is rare for this topic.','visible','','2026-09-08 00:12:40.563957');
INSERT INTO "comments" VALUES(56,41,14,NULL,'Great explanation without dumbing it down.','visible','','2026-09-04 09:12:40.563957');
INSERT INTO "comments" VALUES(57,41,17,55,'Good point @julia_s, I had the same question.','visible','','2026-09-08 18:12:40.563957');
INSERT INTO "comments" VALUES(58,34,4,NULL,'Helpful reminder. I definitely do not get enough sleep.','visible','','2026-08-21 11:12:40.563957');
INSERT INTO "comments" VALUES(59,34,21,NULL,'Clear, calm and not preachy. Thank you.','visible','','2026-08-13 22:12:40.563957');
INSERT INTO "comments" VALUES(60,34,16,NULL,'My doctor told me the same thing, good to see it explained.','visible','','2026-08-17 15:12:40.563957');
INSERT INTO "comments" VALUES(61,34,20,58,'@seo there is a related article in this category too.','visible','','2026-08-22 08:12:40.563957');
INSERT INTO "comments" VALUES(62,33,21,NULL,'Rinsing containers really does matter, our local plant says so too.','visible','','2026-08-19 14:12:40.563957');
INSERT INTO "comments" VALUES(63,33,20,NULL,'Useful facts for our neighbourhood climate group.','visible','','2026-08-16 23:12:40.563957');
INSERT INTO "comments" VALUES(64,33,14,NULL,'I did not realise how much the ocean absorbs.','visible','','2026-08-22 05:12:40.563957');
INSERT INTO "comments" VALUES(65,33,16,62,'@lucia_g totally agree with you.','visible','','2026-08-19 19:12:40.563957');
INSERT INTO "comments" VALUES(66,20,5,NULL,'Would love a follow-up on how this works for small companies.','visible','','2026-07-08 14:12:40.563957');
INSERT INTO "comments" VALUES(67,2,10,NULL,'My doctor told me the same thing, good to see it explained.','visible','','2026-05-13 14:12:40.563957');
INSERT INTO "comments" VALUES(68,2,5,NULL,'The practical tips at the end are the best part.','visible','','2026-05-19 14:12:40.563957');
INSERT INTO "comments" VALUES(69,31,5,NULL,'The diagram in my head finally makes sense now.','visible','','2026-08-04 01:12:40.563957');
INSERT INTO "comments" VALUES(70,31,17,NULL,'I am going to use this with my students next week.','visible','','2026-08-11 19:12:40.563957');
INSERT INTO "comments" VALUES(71,18,15,NULL,'Started doing this last month and already feel the difference.','visible','','2026-06-28 05:12:40.563957');
INSERT INTO "comments" VALUES(72,46,14,NULL,'Useful facts for our neighbourhood climate group.','visible','','2026-09-24 00:12:40.563957');
INSERT INTO "comments" VALUES(73,46,11,NULL,'Would like to see numbers for different countries.','visible','','2026-09-30 19:12:40.563957');
INSERT INTO "comments" VALUES(74,46,3,NULL,'Our city just started a tree planting programme, this explains why.','visible','','2026-09-24 15:12:40.563957');
INSERT INTO "comments" VALUES(75,46,14,NULL,'Balanced article, thanks for not overselling it.','visible','','2026-09-23 18:12:40.563957');
INSERT INTO "comments" VALUES(76,46,13,72,'@elif_y there is a related article in this category too.','visible','','2026-09-24 12:12:40.563957');
INSERT INTO "comments" VALUES(77,24,12,NULL,'My doctor told me the same thing, good to see it explained.','visible','','2026-07-27 17:12:40.563957');
INSERT INTO "comments" VALUES(78,24,4,NULL,'Started doing this last month and already feel the difference.','visible','','2026-07-21 16:12:40.563957');
INSERT INTO "comments" VALUES(79,24,20,NULL,'Helpful reminder. I definitely do not get enough sleep.','visible','','2026-07-21 01:12:40.563957');
INSERT INTO "comments" VALUES(80,55,11,NULL,'I am going to use this with my students next week.','visible','','2026-10-25 03:12:40.563957');
INSERT INTO "comments" VALUES(81,55,18,NULL,'Fascinating. I had no idea about the calibration part.','visible','','2026-10-14 11:12:40.563957');
INSERT INTO "comments" VALUES(82,55,11,NULL,'Clear and accurate, which is rare for this topic.','visible','','2026-10-17 01:12:40.563957');
INSERT INTO "comments" VALUES(83,55,4,80,'@ben_carter there is a related article in this category too.','visible','','2026-10-25 06:12:40.563957');
INSERT INTO "comments" VALUES(84,59,4,NULL,'This finally made it click for me, thanks.','visible','','2026-10-30 11:12:40.563957');
INSERT INTO "comments" VALUES(85,59,15,NULL,'Bookmarking this for our team onboarding.','visible','','2026-10-28 09:12:40.563957');
INSERT INTO "comments" VALUES(86,59,17,NULL,'Shared this with my parents. Very clear.','visible','','2026-11-03 12:12:40.563957');
INSERT INTO "comments" VALUES(87,59,20,NULL,'Would love a follow-up on how this works for small companies.','visible','','2026-11-05 18:12:40.563957');
INSERT INTO "comments" VALUES(88,9,3,NULL,'I did not realise how much the ocean absorbs.','visible','','2026-06-05 07:12:40.563957');
INSERT INTO "comments" VALUES(89,9,13,NULL,'Balanced article, thanks for not overselling it.','visible','','2026-06-08 23:12:40.563957');
INSERT INTO "comments" VALUES(90,9,4,88,'@moderator there is a related article in this category too.','visible','','2026-06-06 10:12:40.563957');
INSERT INTO "comments" VALUES(91,53,12,NULL,'Shared this with my parents. Very clear.','visible','','2026-10-07 13:12:40.563957');
INSERT INTO "comments" VALUES(92,53,21,NULL,'Good overview. The part about recovery options is the one people forget.','visible','','2026-10-07 01:12:40.563957');
INSERT INTO "comments" VALUES(93,53,11,NULL,'Bookmarking this for our team onboarding.','visible','','2026-10-12 14:12:40.563957');
INSERT INTO "comments" VALUES(94,53,20,91,'Thanks @chi_nguyen, that is helpful.','visible','','2026-10-07 17:12:40.563957');
INSERT INTO "comments" VALUES(95,6,4,NULL,'My doctor told me the same thing, good to see it explained.','visible','','2026-06-02 22:12:40.563957');
INSERT INTO "comments" VALUES(96,6,19,NULL,'Appreciate that this sticks to what the evidence says.','visible','','2026-05-24 11:12:40.563957');
INSERT INTO "comments" VALUES(97,6,5,NULL,'Clear, calm and not preachy. Thank you.','visible','','2026-05-21 19:12:40.563957');
INSERT INTO "comments" VALUES(98,38,16,NULL,'Wish I had read this in my twenties.','visible','','2026-09-03 17:12:40.563957');
INSERT INTO "comments" VALUES(99,38,15,NULL,'Clear explanation, I sent it to my younger brother.','visible','','2026-08-28 04:12:40.563957');
INSERT INTO "comments" VALUES(100,38,19,NULL,'Very practical. Setting up an automatic transfer today.','visible','','2026-09-06 07:12:40.563957');
INSERT INTO "comments" VALUES(101,38,16,NULL,'Good reminder that profit is not the same as cash.','visible','','2026-09-06 11:12:40.563957');
INSERT INTO "comments" VALUES(102,50,3,NULL,'Clear explanation, I sent it to my younger brother.','visible','','2026-10-03 02:12:40.563957');
INSERT INTO "comments" VALUES(103,50,11,NULL,'Would love a piece on how pensions work next.','visible','','2026-10-09 23:12:40.563957');
INSERT INTO "comments" VALUES(104,50,5,NULL,'Wish I had read this in my twenties.','visible','','2026-09-30 16:12:40.563957');
INSERT INTO "comments" VALUES(105,50,20,102,'Good point @moderator, I had the same question.','visible','','2026-10-03 14:12:40.563957');
INSERT INTO "comments" VALUES(106,58,14,NULL,'This finally made it click for me, thanks.','visible','','2026-10-31 03:12:40.563957');
INSERT INTO "comments" VALUES(107,58,19,NULL,'Would love a follow-up on how this works for small companies.','visible','','2026-10-29 19:12:40.563957');
INSERT INTO "comments" VALUES(108,58,13,106,'@elif_y totally agree with you.','visible','','2026-10-31 20:12:40.563957');
INSERT INTO "comments" VALUES(109,3,21,NULL,'As a teacher, I agree with every point here.','visible','','2026-05-12 07:12:40.563957');
INSERT INTO "comments" VALUES(110,3,18,NULL,'Our teachers started doing low-stakes quizzes and it helps.','visible','','2026-05-26 08:12:40.563957');
INSERT INTO "comments" VALUES(111,3,14,109,'@lucia_g there is a related article in this category too.','visible','','2026-05-13 10:12:40.563957');
INSERT INTO "comments" VALUES(112,26,17,NULL,'The practical tips at the end are the best part.','visible','','2026-07-30 00:12:40.563957');
INSERT INTO "comments" VALUES(113,26,14,NULL,'Clear, calm and not preachy. Thank you.','visible','','2026-07-20 17:12:40.563957');
INSERT INTO "comments" VALUES(114,26,5,NULL,'Helpful reminder. I definitely do not get enough sleep.','visible','','2026-07-20 14:12:40.563957');
INSERT INTO "comments" VALUES(115,26,14,112,'Thanks @huong_le, that is helpful.','visible','','2026-07-30 14:12:40.563957');
INSERT INTO "comments" VALUES(116,36,11,NULL,'I am going to use this with my students next week.','visible','','2026-08-27 07:12:40.563957');
INSERT INTO "comments" VALUES(117,36,12,NULL,'Great explanation without dumbing it down.','visible','','2026-08-20 14:12:40.563957');
INSERT INTO "comments" VALUES(118,36,21,NULL,'Would be great to have a reading list at the end.','visible','','2026-08-28 12:12:40.563957');
INSERT INTO "comments" VALUES(119,19,16,NULL,'Lateral reading is such a useful habit.','visible','','2026-06-28 14:12:40.563957');
INSERT INTO "comments" VALUES(120,25,4,NULL,'The rule of 72 trick is great.','visible','','2026-07-15 13:12:40.563957');
INSERT INTO "comments" VALUES(121,27,3,NULL,'Would love a follow-up on how this works for small companies.','visible','','2026-07-30 01:12:40.563957');
INSERT INTO "comments" VALUES(122,27,4,NULL,'Bookmarking this for our team onboarding.','visible','','2026-08-02 08:12:40.563957');
INSERT INTO "comments" VALUES(123,27,17,NULL,'Good overview. The part about recovery options is the one people forget.','visible','','2026-08-05 21:12:40.563957');
INSERT INTO "comments" VALUES(124,27,14,NULL,'This finally made it click for me, thanks.','visible','','2026-07-24 07:12:40.563957');
INSERT INTO "comments" VALUES(125,22,3,NULL,'Would be great to have a reading list at the end.','visible','','2026-07-08 15:12:40.563957');
INSERT INTO "comments" VALUES(126,15,20,NULL,'I did not realise how much the ocean absorbs.','visible','','2026-06-19 17:12:40.563957');
INSERT INTO "comments" VALUES(127,15,13,NULL,'Balanced article, thanks for not overselling it.','visible','','2026-06-17 13:12:40.563957');
INSERT INTO "comments" VALUES(128,15,10,126,'Thanks @kenji_t, that is helpful.','visible','','2026-06-20 16:12:40.563957');
INSERT INTO "comments" VALUES(129,60,16,NULL,'Click here for FREE MONEY and a crypto giveaway!!! www.example-win.biz www.example-win.biz/now www.bonus.example','pending','Auto-flagged: contains spam keyword(s): free money, crypto giveaway, click here','2026-10-31 02:12:40.563957');
INSERT INTO "comments" VALUES(130,59,18,NULL,'Anyone who believes this is an idiot.','visible','','2026-10-30 22:12:40.563957');
CREATE TABLE document_tags (
	document_id INTEGER NOT NULL, 
	tag_id INTEGER NOT NULL, 
	PRIMARY KEY (document_id, tag_id), 
	FOREIGN KEY(document_id) REFERENCES documents (id) ON DELETE CASCADE, 
	FOREIGN KEY(tag_id) REFERENCES tags (id) ON DELETE CASCADE
);
INSERT INTO "document_tags" VALUES(35,9);
INSERT INTO "document_tags" VALUES(35,29);
INSERT INTO "document_tags" VALUES(46,25);
INSERT INTO "document_tags" VALUES(46,18);
INSERT INTO "document_tags" VALUES(46,24);
INSERT INTO "document_tags" VALUES(15,7);
INSERT INTO "document_tags" VALUES(15,24);
INSERT INTO "document_tags" VALUES(13,25);
INSERT INTO "document_tags" VALUES(13,24);
INSERT INTO "document_tags" VALUES(31,10);
INSERT INTO "document_tags" VALUES(31,14);
INSERT INTO "document_tags" VALUES(31,6);
INSERT INTO "document_tags" VALUES(20,1);
INSERT INTO "document_tags" VALUES(20,2);
INSERT INTO "document_tags" VALUES(45,23);
INSERT INTO "document_tags" VALUES(45,22);
INSERT INTO "document_tags" VALUES(32,12);
INSERT INTO "document_tags" VALUES(32,13);
INSERT INTO "document_tags" VALUES(32,11);
INSERT INTO "document_tags" VALUES(21,22);
INSERT INTO "document_tags" VALUES(21,13);
INSERT INTO "document_tags" VALUES(58,3);
INSERT INTO "document_tags" VALUES(58,4);
INSERT INTO "document_tags" VALUES(44,5);
INSERT INTO "document_tags" VALUES(44,4);
INSERT INTO "document_tags" VALUES(33,7);
INSERT INTO "document_tags" VALUES(33,24);
INSERT INTO "document_tags" VALUES(59,4);
INSERT INTO "document_tags" VALUES(59,6);
INSERT INTO "document_tags" VALUES(59,2);
INSERT INTO "document_tags" VALUES(47,4);
INSERT INTO "document_tags" VALUES(47,8);
INSERT INTO "document_tags" VALUES(8,19);
INSERT INTO "document_tags" VALUES(8,3);
INSERT INTO "document_tags" VALUES(8,31);
INSERT INTO "document_tags" VALUES(60,29);
INSERT INTO "document_tags" VALUES(60,9);
INSERT INTO "document_tags" VALUES(48,18);
INSERT INTO "document_tags" VALUES(48,11);
INSERT INTO "document_tags" VALUES(22,10);
INSERT INTO "document_tags" VALUES(9,7);
INSERT INTO "document_tags" VALUES(9,24);
INSERT INTO "document_tags" VALUES(50,30);
INSERT INTO "document_tags" VALUES(50,8);
INSERT INTO "document_tags" VALUES(19,19);
INSERT INTO "document_tags" VALUES(19,15);
INSERT INTO "document_tags" VALUES(23,17);
INSERT INTO "document_tags" VALUES(23,8);
INSERT INTO "document_tags" VALUES(34,12);
INSERT INTO "document_tags" VALUES(34,6);
INSERT INTO "document_tags" VALUES(24,23);
INSERT INTO "document_tags" VALUES(10,15);
INSERT INTO "document_tags" VALUES(10,19);
INSERT INTO "document_tags" VALUES(49,19);
INSERT INTO "document_tags" VALUES(49,31);
INSERT INTO "document_tags" VALUES(11,6);
INSERT INTO "document_tags" VALUES(11,9);
INSERT INTO "document_tags" VALUES(37,24);
INSERT INTO "document_tags" VALUES(37,27);
INSERT INTO "document_tags" VALUES(26,21);
INSERT INTO "document_tags" VALUES(26,20);
INSERT INTO "document_tags" VALUES(7,29);
INSERT INTO "document_tags" VALUES(7,31);
INSERT INTO "document_tags" VALUES(36,14);
INSERT INTO "document_tags" VALUES(36,10);
INSERT INTO "document_tags" VALUES(52,19);
INSERT INTO "document_tags" VALUES(52,8);
INSERT INTO "document_tags" VALUES(38,29);
INSERT INTO "document_tags" VALUES(25,9);
INSERT INTO "document_tags" VALUES(25,29);
INSERT INTO "document_tags" VALUES(39,26);
INSERT INTO "document_tags" VALUES(51,5);
INSERT INTO "document_tags" VALUES(51,3);
INSERT INTO "document_tags" VALUES(51,2);
INSERT INTO "document_tags" VALUES(4,11);
INSERT INTO "document_tags" VALUES(4,12);
INSERT INTO "document_tags" VALUES(4,13);
INSERT INTO "document_tags" VALUES(41,11);
INSERT INTO "document_tags" VALUES(41,15);
INSERT INTO "document_tags" VALUES(41,12);
INSERT INTO "document_tags" VALUES(28,29);
INSERT INTO "document_tags" VALUES(28,9);
INSERT INTO "document_tags" VALUES(14,8);
INSERT INTO "document_tags" VALUES(14,9);
INSERT INTO "document_tags" VALUES(55,14);
INSERT INTO "document_tags" VALUES(55,10);
INSERT INTO "document_tags" VALUES(12,26);
INSERT INTO "document_tags" VALUES(12,23);
INSERT INTO "document_tags" VALUES(12,24);
INSERT INTO "document_tags" VALUES(6,20);
INSERT INTO "document_tags" VALUES(6,21);
INSERT INTO "document_tags" VALUES(40,19);
INSERT INTO "document_tags" VALUES(2,12);
INSERT INTO "document_tags" VALUES(2,13);
INSERT INTO "document_tags" VALUES(5,15);
INSERT INTO "document_tags" VALUES(5,17);
INSERT INTO "document_tags" VALUES(16,30);
INSERT INTO "document_tags" VALUES(16,29);
INSERT INTO "document_tags" VALUES(27,1);
INSERT INTO "document_tags" VALUES(27,2);
INSERT INTO "document_tags" VALUES(27,3);
INSERT INTO "document_tags" VALUES(42,9);
INSERT INTO "document_tags" VALUES(42,30);
INSERT INTO "document_tags" VALUES(53,1);
INSERT INTO "document_tags" VALUES(53,3);
INSERT INTO "document_tags" VALUES(3,19);
INSERT INTO "document_tags" VALUES(3,17);
INSERT INTO "document_tags" VALUES(17,6);
INSERT INTO "document_tags" VALUES(17,7);
INSERT INTO "document_tags" VALUES(18,22);
INSERT INTO "document_tags" VALUES(18,21);
INSERT INTO "document_tags" VALUES(29,13);
INSERT INTO "document_tags" VALUES(29,12);
INSERT INTO "document_tags" VALUES(1,28);
INSERT INTO "document_tags" VALUES(1,24);
INSERT INTO "document_tags" VALUES(57,8);
INSERT INTO "document_tags" VALUES(57,29);
INSERT INTO "document_tags" VALUES(30,15);
INSERT INTO "document_tags" VALUES(30,17);
INSERT INTO "document_tags" VALUES(30,19);
INSERT INTO "document_tags" VALUES(56,11);
INSERT INTO "document_tags" VALUES(56,18);
INSERT INTO "document_tags" VALUES(54,16);
INSERT INTO "document_tags" VALUES(54,15);
INSERT INTO "document_tags" VALUES(43,20);
INSERT INTO "document_tags" VALUES(43,31);
INSERT INTO "document_tags" VALUES(43,19);
CREATE TABLE document_views (
	id INTEGER NOT NULL, 
	document_id INTEGER NOT NULL, 
	user_id INTEGER, 
	timestamp DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(document_id) REFERENCES documents (id) ON DELETE CASCADE, 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE SET NULL
);
INSERT INTO "document_views" VALUES(1,2,NULL,'2026-10-29 05:13:40.563957');
INSERT INTO "document_views" VALUES(2,2,NULL,'2026-10-18 12:42:40.563957');
INSERT INTO "document_views" VALUES(3,2,NULL,'2026-10-30 20:30:40.563957');
INSERT INTO "document_views" VALUES(4,2,NULL,'2026-10-30 11:16:40.563957');
INSERT INTO "document_views" VALUES(5,2,NULL,'2026-10-21 13:05:40.563957');
INSERT INTO "document_views" VALUES(6,2,NULL,'2026-10-29 13:52:40.563957');
INSERT INTO "document_views" VALUES(7,2,NULL,'2026-10-31 00:52:40.563957');
INSERT INTO "document_views" VALUES(8,2,NULL,'2026-10-31 04:53:40.563957');
INSERT INTO "document_views" VALUES(9,2,NULL,'2026-10-14 23:11:40.563957');
INSERT INTO "document_views" VALUES(10,2,NULL,'2026-10-23 11:46:40.563957');
INSERT INTO "document_views" VALUES(11,2,NULL,'2026-10-27 10:55:40.563957');
INSERT INTO "document_views" VALUES(12,2,NULL,'2026-10-31 04:25:40.563957');
INSERT INTO "document_views" VALUES(13,2,NULL,'2026-10-23 11:17:40.563957');
INSERT INTO "document_views" VALUES(14,3,NULL,'2026-10-05 00:14:40.563957');
INSERT INTO "document_views" VALUES(15,3,NULL,'2026-10-15 20:29:40.563957');
INSERT INTO "document_views" VALUES(16,3,NULL,'2026-10-27 17:42:40.563957');
INSERT INTO "document_views" VALUES(17,3,NULL,'2026-10-29 09:11:40.563957');
INSERT INTO "document_views" VALUES(18,3,NULL,'2026-10-26 20:25:40.563957');
INSERT INTO "document_views" VALUES(19,3,NULL,'2026-10-05 04:44:40.563957');
INSERT INTO "document_views" VALUES(20,3,NULL,'2026-10-30 10:00:40.563957');
INSERT INTO "document_views" VALUES(21,3,NULL,'2026-10-02 03:48:40.563957');
INSERT INTO "document_views" VALUES(22,3,NULL,'2026-10-30 23:56:40.563957');
INSERT INTO "document_views" VALUES(23,3,NULL,'2026-10-21 02:41:40.563957');
INSERT INTO "document_views" VALUES(24,3,NULL,'2026-10-05 04:52:40.563957');
INSERT INTO "document_views" VALUES(25,3,NULL,'2026-10-06 18:36:40.563957');
INSERT INTO "document_views" VALUES(26,3,NULL,'2026-10-26 16:15:40.563957');
INSERT INTO "document_views" VALUES(27,3,NULL,'2026-10-08 20:53:40.563957');
INSERT INTO "document_views" VALUES(28,3,NULL,'2026-10-17 08:53:40.563957');
INSERT INTO "document_views" VALUES(29,3,NULL,'2026-10-20 08:25:40.563957');
INSERT INTO "document_views" VALUES(30,3,NULL,'2026-10-09 20:59:40.563957');
INSERT INTO "document_views" VALUES(31,3,NULL,'2026-10-05 03:40:40.563957');
INSERT INTO "document_views" VALUES(32,3,NULL,'2026-10-04 02:37:40.563957');
INSERT INTO "document_views" VALUES(33,3,NULL,'2026-10-28 03:33:40.563957');
INSERT INTO "document_views" VALUES(34,3,NULL,'2026-10-13 01:54:40.563957');
INSERT INTO "document_views" VALUES(35,3,NULL,'2026-10-27 10:34:40.563957');
INSERT INTO "document_views" VALUES(36,3,NULL,'2026-10-28 19:30:40.563957');
INSERT INTO "document_views" VALUES(37,3,NULL,'2026-10-28 09:34:40.563957');
INSERT INTO "document_views" VALUES(38,3,NULL,'2026-10-07 13:57:40.563957');
INSERT INTO "document_views" VALUES(39,3,NULL,'2026-10-22 05:28:40.563957');
INSERT INTO "document_views" VALUES(40,3,NULL,'2026-10-30 16:45:40.563957');
INSERT INTO "document_views" VALUES(41,3,NULL,'2026-10-09 05:42:40.563957');
INSERT INTO "document_views" VALUES(42,3,NULL,'2026-10-31 02:45:40.563957');
INSERT INTO "document_views" VALUES(43,3,NULL,'2026-10-16 22:16:40.563957');
INSERT INTO "document_views" VALUES(44,3,NULL,'2026-10-29 16:08:40.563957');
INSERT INTO "document_views" VALUES(45,3,NULL,'2026-10-19 16:37:40.563957');
INSERT INTO "document_views" VALUES(46,3,NULL,'2026-10-20 03:23:40.563957');
INSERT INTO "document_views" VALUES(47,3,NULL,'2026-10-30 07:37:40.563957');
INSERT INTO "document_views" VALUES(48,3,NULL,'2026-10-05 12:35:40.563957');
INSERT INTO "document_views" VALUES(49,3,NULL,'2026-10-30 18:36:40.563957');
INSERT INTO "document_views" VALUES(50,3,NULL,'2026-10-19 02:09:40.563957');
INSERT INTO "document_views" VALUES(51,3,NULL,'2026-10-24 05:47:40.563957');
INSERT INTO "document_views" VALUES(52,3,NULL,'2026-10-27 05:51:40.563957');
INSERT INTO "document_views" VALUES(53,3,NULL,'2026-10-06 00:02:40.563957');
INSERT INTO "document_views" VALUES(54,3,NULL,'2026-10-14 08:27:40.563957');
INSERT INTO "document_views" VALUES(55,3,NULL,'2026-10-30 12:06:40.563957');
INSERT INTO "document_views" VALUES(56,3,NULL,'2026-10-06 17:20:40.563957');
INSERT INTO "document_views" VALUES(57,3,NULL,'2026-10-03 01:56:40.563957');
INSERT INTO "document_views" VALUES(58,3,NULL,'2026-10-04 23:08:40.563957');
INSERT INTO "document_views" VALUES(59,3,NULL,'2026-10-08 01:10:40.563957');
INSERT INTO "document_views" VALUES(60,4,NULL,'2026-10-12 19:52:40.563957');
INSERT INTO "document_views" VALUES(61,4,NULL,'2026-10-10 17:09:40.563957');
INSERT INTO "document_views" VALUES(62,4,NULL,'2026-10-09 22:44:40.563957');
INSERT INTO "document_views" VALUES(63,4,NULL,'2026-10-27 07:16:40.563957');
INSERT INTO "document_views" VALUES(64,4,NULL,'2026-10-31 05:53:40.563957');
INSERT INTO "document_views" VALUES(65,4,NULL,'2026-10-07 23:37:40.563957');
INSERT INTO "document_views" VALUES(66,4,NULL,'2026-10-28 15:30:40.563957');
INSERT INTO "document_views" VALUES(67,4,NULL,'2026-10-25 23:26:40.563957');
INSERT INTO "document_views" VALUES(68,5,NULL,'2026-10-28 20:00:40.563957');
INSERT INTO "document_views" VALUES(69,5,NULL,'2026-10-28 04:50:40.563957');
INSERT INTO "document_views" VALUES(70,5,NULL,'2026-10-02 21:41:40.563957');
INSERT INTO "document_views" VALUES(71,5,NULL,'2026-10-25 13:49:40.563957');
INSERT INTO "document_views" VALUES(72,5,NULL,'2026-10-24 12:54:40.563957');
INSERT INTO "document_views" VALUES(73,5,NULL,'2026-10-26 06:16:40.563957');
INSERT INTO "document_views" VALUES(74,5,NULL,'2026-10-30 22:18:40.563957');
INSERT INTO "document_views" VALUES(75,5,NULL,'2026-10-29 22:09:40.563957');
INSERT INTO "document_views" VALUES(76,6,NULL,'2026-10-23 20:30:40.563957');
INSERT INTO "document_views" VALUES(77,6,NULL,'2026-10-23 13:45:40.563957');
INSERT INTO "document_views" VALUES(78,6,NULL,'2026-10-30 11:32:40.563957');
INSERT INTO "document_views" VALUES(79,6,NULL,'2026-10-29 05:42:40.563957');
INSERT INTO "document_views" VALUES(80,6,NULL,'2026-10-14 07:09:40.563957');
INSERT INTO "document_views" VALUES(81,6,NULL,'2026-10-20 12:50:40.563957');
INSERT INTO "document_views" VALUES(82,6,NULL,'2026-10-14 08:19:40.563957');
INSERT INTO "document_views" VALUES(83,6,NULL,'2026-10-28 16:29:40.563957');
INSERT INTO "document_views" VALUES(84,6,NULL,'2026-10-30 08:32:40.563957');
INSERT INTO "document_views" VALUES(85,7,NULL,'2026-10-16 02:57:40.563957');
INSERT INTO "document_views" VALUES(86,7,NULL,'2026-10-13 20:57:40.563957');
INSERT INTO "document_views" VALUES(87,7,NULL,'2026-10-20 08:27:40.563957');
INSERT INTO "document_views" VALUES(88,7,NULL,'2026-10-23 17:28:40.563957');
INSERT INTO "document_views" VALUES(89,7,NULL,'2026-10-14 12:17:40.563957');
INSERT INTO "document_views" VALUES(90,7,NULL,'2026-10-29 16:51:40.563957');
INSERT INTO "document_views" VALUES(91,7,NULL,'2026-10-15 18:16:40.563957');
INSERT INTO "document_views" VALUES(92,7,NULL,'2026-10-15 01:16:40.563957');
INSERT INTO "document_views" VALUES(93,7,NULL,'2026-10-17 20:56:40.563957');
INSERT INTO "document_views" VALUES(94,7,NULL,'2026-10-24 07:12:40.563957');
INSERT INTO "document_views" VALUES(95,7,NULL,'2026-10-27 00:02:40.563957');
INSERT INTO "document_views" VALUES(96,7,NULL,'2026-10-23 11:25:40.563957');
INSERT INTO "document_views" VALUES(97,7,NULL,'2026-10-17 20:13:40.563957');
INSERT INTO "document_views" VALUES(98,7,NULL,'2026-10-22 16:07:40.563957');
INSERT INTO "document_views" VALUES(99,7,NULL,'2026-10-14 13:46:40.563957');
INSERT INTO "document_views" VALUES(100,7,NULL,'2026-10-22 01:25:40.563957');
INSERT INTO "document_views" VALUES(101,7,NULL,'2026-10-15 21:31:40.563957');
INSERT INTO "document_views" VALUES(102,7,NULL,'2026-10-20 09:36:40.563957');
INSERT INTO "document_views" VALUES(103,7,NULL,'2026-10-18 04:01:40.563957');
INSERT INTO "document_views" VALUES(104,7,NULL,'2026-10-09 23:11:40.563957');
INSERT INTO "document_views" VALUES(105,7,NULL,'2026-10-15 23:32:40.563957');
INSERT INTO "document_views" VALUES(106,7,NULL,'2026-10-10 02:11:40.563957');
INSERT INTO "document_views" VALUES(107,7,NULL,'2026-10-30 22:51:40.563957');
INSERT INTO "document_views" VALUES(108,7,NULL,'2026-10-01 10:21:40.563957');
INSERT INTO "document_views" VALUES(109,7,NULL,'2026-10-08 04:43:40.563957');
INSERT INTO "document_views" VALUES(110,7,NULL,'2026-10-22 09:43:40.563957');
INSERT INTO "document_views" VALUES(111,7,NULL,'2026-10-18 07:26:40.563957');
INSERT INTO "document_views" VALUES(112,7,NULL,'2026-10-24 17:34:40.563957');
INSERT INTO "document_views" VALUES(113,7,NULL,'2026-10-27 08:49:40.563957');
INSERT INTO "document_views" VALUES(114,7,NULL,'2026-10-15 03:34:40.563957');
INSERT INTO "document_views" VALUES(115,7,NULL,'2026-10-10 23:44:40.563957');
INSERT INTO "document_views" VALUES(116,7,NULL,'2026-10-29 07:27:40.563957');
INSERT INTO "document_views" VALUES(117,7,NULL,'2026-10-21 05:30:40.563957');
INSERT INTO "document_views" VALUES(118,7,NULL,'2026-10-20 03:04:40.563957');
INSERT INTO "document_views" VALUES(119,7,NULL,'2026-10-22 15:21:40.563957');
INSERT INTO "document_views" VALUES(120,7,NULL,'2026-10-15 12:08:40.563957');
INSERT INTO "document_views" VALUES(121,7,NULL,'2026-10-17 16:06:40.563957');
INSERT INTO "document_views" VALUES(122,7,NULL,'2026-10-17 13:59:40.563957');
INSERT INTO "document_views" VALUES(123,7,NULL,'2026-10-23 12:30:40.563957');
INSERT INTO "document_views" VALUES(124,7,NULL,'2026-10-23 01:47:40.563957');
INSERT INTO "document_views" VALUES(125,7,NULL,'2026-10-12 15:00:40.563957');
INSERT INTO "document_views" VALUES(126,7,NULL,'2026-10-22 22:46:40.563957');
INSERT INTO "document_views" VALUES(127,7,NULL,'2026-10-08 21:45:40.563957');
INSERT INTO "document_views" VALUES(128,7,NULL,'2026-10-11 13:25:40.563957');
INSERT INTO "document_views" VALUES(129,7,NULL,'2026-10-21 23:03:40.563957');
INSERT INTO "document_views" VALUES(130,7,NULL,'2026-10-28 04:34:40.563957');
INSERT INTO "document_views" VALUES(131,7,NULL,'2026-10-13 23:12:40.563957');
INSERT INTO "document_views" VALUES(132,7,NULL,'2026-10-27 20:18:40.563957');
INSERT INTO "document_views" VALUES(133,7,NULL,'2026-10-06 04:27:40.563957');
INSERT INTO "document_views" VALUES(134,7,NULL,'2026-10-29 23:19:40.563957');
INSERT INTO "document_views" VALUES(135,7,NULL,'2026-10-25 02:00:40.563957');
INSERT INTO "document_views" VALUES(136,7,NULL,'2026-10-14 05:01:40.563957');
INSERT INTO "document_views" VALUES(137,7,NULL,'2026-10-23 19:55:40.563957');
INSERT INTO "document_views" VALUES(138,7,NULL,'2026-10-19 17:01:40.563957');
INSERT INTO "document_views" VALUES(139,7,NULL,'2026-10-30 16:52:40.563957');
INSERT INTO "document_views" VALUES(140,7,NULL,'2026-10-24 11:16:40.563957');
INSERT INTO "document_views" VALUES(141,7,NULL,'2026-10-04 06:32:40.563957');
INSERT INTO "document_views" VALUES(142,7,NULL,'2026-10-07 11:33:40.563957');
INSERT INTO "document_views" VALUES(143,7,NULL,'2026-10-25 07:00:40.563957');
INSERT INTO "document_views" VALUES(144,7,NULL,'2026-10-03 21:01:40.563957');
INSERT INTO "document_views" VALUES(145,7,NULL,'2026-10-11 16:54:40.563957');
INSERT INTO "document_views" VALUES(146,7,NULL,'2026-10-19 12:34:40.563957');
INSERT INTO "document_views" VALUES(147,8,NULL,'2026-10-21 21:54:40.563957');
INSERT INTO "document_views" VALUES(148,8,NULL,'2026-10-24 06:13:40.563957');
INSERT INTO "document_views" VALUES(149,8,NULL,'2026-10-24 08:23:40.563957');
INSERT INTO "document_views" VALUES(150,8,NULL,'2026-10-14 17:24:40.563957');
INSERT INTO "document_views" VALUES(151,8,NULL,'2026-10-13 15:15:40.563957');
INSERT INTO "document_views" VALUES(152,8,NULL,'2026-10-04 09:58:40.563957');
INSERT INTO "document_views" VALUES(153,8,NULL,'2026-10-20 17:46:40.563957');
INSERT INTO "document_views" VALUES(154,8,NULL,'2026-10-18 08:35:40.563957');
INSERT INTO "document_views" VALUES(155,8,NULL,'2026-10-30 09:16:40.563957');
INSERT INTO "document_views" VALUES(156,8,NULL,'2026-10-23 15:27:40.563957');
INSERT INTO "document_views" VALUES(157,8,NULL,'2026-10-29 22:20:40.563957');
INSERT INTO "document_views" VALUES(158,8,NULL,'2026-10-24 23:59:40.563957');
INSERT INTO "document_views" VALUES(159,8,NULL,'2026-10-22 19:41:40.563957');
INSERT INTO "document_views" VALUES(160,8,NULL,'2026-10-11 18:16:40.563957');
INSERT INTO "document_views" VALUES(161,8,NULL,'2026-10-27 16:49:40.563957');
INSERT INTO "document_views" VALUES(162,8,NULL,'2026-10-28 04:25:40.563957');
INSERT INTO "document_views" VALUES(163,8,NULL,'2026-10-22 12:48:40.563957');
INSERT INTO "document_views" VALUES(164,8,NULL,'2026-10-30 19:16:40.563957');
INSERT INTO "document_views" VALUES(165,8,NULL,'2026-10-29 04:52:40.563957');
INSERT INTO "document_views" VALUES(166,8,NULL,'2026-10-10 08:58:40.563957');
INSERT INTO "document_views" VALUES(167,8,NULL,'2026-10-31 06:09:40.563957');
INSERT INTO "document_views" VALUES(168,8,NULL,'2026-10-04 00:24:40.563957');
INSERT INTO "document_views" VALUES(169,8,NULL,'2026-10-08 10:00:40.563957');
INSERT INTO "document_views" VALUES(170,8,NULL,'2026-10-30 02:54:40.563957');
INSERT INTO "document_views" VALUES(171,8,NULL,'2026-10-22 03:18:40.563957');
INSERT INTO "document_views" VALUES(172,8,NULL,'2026-10-19 23:46:40.563957');
INSERT INTO "document_views" VALUES(173,8,NULL,'2026-10-22 22:28:40.563957');
INSERT INTO "document_views" VALUES(174,8,NULL,'2026-10-12 01:29:40.563957');
INSERT INTO "document_views" VALUES(175,8,NULL,'2026-10-18 03:18:40.563957');
INSERT INTO "document_views" VALUES(176,8,NULL,'2026-10-11 01:37:40.563957');
INSERT INTO "document_views" VALUES(177,8,NULL,'2026-10-03 03:31:40.563957');
INSERT INTO "document_views" VALUES(178,8,NULL,'2026-10-18 20:34:40.563957');
INSERT INTO "document_views" VALUES(179,8,NULL,'2026-10-18 18:24:40.563957');
INSERT INTO "document_views" VALUES(180,8,NULL,'2026-10-25 00:26:40.563957');
INSERT INTO "document_views" VALUES(181,8,NULL,'2026-10-30 07:38:40.563957');
INSERT INTO "document_views" VALUES(182,8,NULL,'2026-10-08 22:55:40.563957');
INSERT INTO "document_views" VALUES(183,8,NULL,'2026-10-30 20:55:40.563957');
INSERT INTO "document_views" VALUES(184,8,NULL,'2026-10-07 10:43:40.563957');
INSERT INTO "document_views" VALUES(185,8,NULL,'2026-10-09 11:53:40.563957');
INSERT INTO "document_views" VALUES(186,8,NULL,'2026-10-10 19:21:40.563957');
INSERT INTO "document_views" VALUES(187,8,NULL,'2026-10-20 08:38:40.563957');
INSERT INTO "document_views" VALUES(188,8,NULL,'2026-10-24 13:56:40.563957');
INSERT INTO "document_views" VALUES(189,8,NULL,'2026-10-17 06:47:40.563957');
INSERT INTO "document_views" VALUES(190,8,NULL,'2026-10-07 14:29:40.563957');
INSERT INTO "document_views" VALUES(191,8,NULL,'2026-10-30 18:51:40.563957');
INSERT INTO "document_views" VALUES(192,8,NULL,'2026-10-16 15:31:40.563957');
INSERT INTO "document_views" VALUES(193,8,NULL,'2026-10-13 16:21:40.563957');
INSERT INTO "document_views" VALUES(194,8,NULL,'2026-10-29 13:24:40.563957');
INSERT INTO "document_views" VALUES(195,8,NULL,'2026-10-02 21:59:40.563957');
INSERT INTO "document_views" VALUES(196,8,NULL,'2026-10-17 12:50:40.563957');
INSERT INTO "document_views" VALUES(197,8,NULL,'2026-10-11 15:20:40.563957');
INSERT INTO "document_views" VALUES(198,8,NULL,'2026-10-23 10:59:40.563957');
INSERT INTO "document_views" VALUES(199,8,NULL,'2026-10-27 22:50:40.563957');
INSERT INTO "document_views" VALUES(200,8,NULL,'2026-10-09 04:15:40.563957');
INSERT INTO "document_views" VALUES(201,8,NULL,'2026-10-27 15:49:40.563957');
INSERT INTO "document_views" VALUES(202,8,NULL,'2026-10-27 15:21:40.563957');
INSERT INTO "document_views" VALUES(203,8,NULL,'2026-10-18 08:24:40.563957');
INSERT INTO "document_views" VALUES(204,8,NULL,'2026-10-25 06:14:40.563957');
INSERT INTO "document_views" VALUES(205,8,NULL,'2026-10-21 20:07:40.563957');
INSERT INTO "document_views" VALUES(206,8,NULL,'2026-10-29 23:58:40.563957');
INSERT INTO "document_views" VALUES(207,8,NULL,'2026-10-25 22:23:40.563957');
INSERT INTO "document_views" VALUES(208,8,NULL,'2026-10-25 10:52:40.563957');
INSERT INTO "document_views" VALUES(209,8,NULL,'2026-10-13 21:47:40.563957');
INSERT INTO "document_views" VALUES(210,8,NULL,'2026-10-19 13:34:40.563957');
INSERT INTO "document_views" VALUES(211,8,NULL,'2026-10-04 04:17:40.563957');
INSERT INTO "document_views" VALUES(212,8,NULL,'2026-10-27 17:20:40.563957');
INSERT INTO "document_views" VALUES(213,8,NULL,'2026-10-21 23:00:40.563957');
INSERT INTO "document_views" VALUES(214,8,NULL,'2026-10-14 09:10:40.563957');
INSERT INTO "document_views" VALUES(215,8,NULL,'2026-10-13 15:55:40.563957');
INSERT INTO "document_views" VALUES(216,8,NULL,'2026-10-11 04:02:40.563957');
INSERT INTO "document_views" VALUES(217,8,NULL,'2026-10-26 17:24:40.563957');
INSERT INTO "document_views" VALUES(218,8,NULL,'2026-10-14 20:45:40.563957');
INSERT INTO "document_views" VALUES(219,8,NULL,'2026-10-15 18:37:40.563957');
INSERT INTO "document_views" VALUES(220,8,NULL,'2026-10-21 13:05:40.563957');
INSERT INTO "document_views" VALUES(221,8,NULL,'2026-10-25 12:25:40.563957');
INSERT INTO "document_views" VALUES(222,8,NULL,'2026-10-25 07:13:40.563957');
INSERT INTO "document_views" VALUES(223,8,NULL,'2026-10-22 20:45:40.563957');
INSERT INTO "document_views" VALUES(224,8,NULL,'2026-10-28 03:05:40.563957');
INSERT INTO "document_views" VALUES(225,8,NULL,'2026-10-13 20:26:40.563957');
INSERT INTO "document_views" VALUES(226,8,NULL,'2026-10-29 12:55:40.563957');
INSERT INTO "document_views" VALUES(227,8,NULL,'2026-10-03 07:39:40.563957');
INSERT INTO "document_views" VALUES(228,8,NULL,'2026-10-28 23:49:40.563957');
INSERT INTO "document_views" VALUES(229,8,NULL,'2026-10-12 21:46:40.563957');
INSERT INTO "document_views" VALUES(230,8,NULL,'2026-10-13 13:18:40.563957');
INSERT INTO "document_views" VALUES(231,8,NULL,'2026-10-18 03:47:40.563957');
INSERT INTO "document_views" VALUES(232,8,NULL,'2026-10-08 21:06:40.563957');
INSERT INTO "document_views" VALUES(233,8,NULL,'2026-10-29 01:05:40.563957');
INSERT INTO "document_views" VALUES(234,8,NULL,'2026-10-26 12:59:40.563957');
INSERT INTO "document_views" VALUES(235,8,NULL,'2026-10-30 05:39:40.563957');
INSERT INTO "document_views" VALUES(236,8,NULL,'2026-10-02 12:19:40.563957');
INSERT INTO "document_views" VALUES(237,8,NULL,'2026-10-27 02:54:40.563957');
INSERT INTO "document_views" VALUES(238,8,NULL,'2026-10-16 14:27:40.563957');
INSERT INTO "document_views" VALUES(239,8,NULL,'2026-10-31 06:47:40.563957');
INSERT INTO "document_views" VALUES(240,8,NULL,'2026-10-18 15:11:40.563957');
INSERT INTO "document_views" VALUES(241,8,NULL,'2026-10-21 19:35:40.563957');
INSERT INTO "document_views" VALUES(242,8,NULL,'2026-10-29 05:27:40.563957');
INSERT INTO "document_views" VALUES(243,8,NULL,'2026-10-27 14:54:40.563957');
INSERT INTO "document_views" VALUES(244,8,NULL,'2026-10-31 04:59:40.563957');
INSERT INTO "document_views" VALUES(245,8,NULL,'2026-10-25 04:41:40.563957');
INSERT INTO "document_views" VALUES(246,8,NULL,'2026-10-18 07:47:40.563957');
INSERT INTO "document_views" VALUES(247,8,NULL,'2026-10-31 02:07:40.563957');
INSERT INTO "document_views" VALUES(248,8,NULL,'2026-10-09 20:50:40.563957');
INSERT INTO "document_views" VALUES(249,8,NULL,'2026-10-30 22:44:40.563957');
INSERT INTO "document_views" VALUES(250,8,NULL,'2026-10-30 17:00:40.563957');
INSERT INTO "document_views" VALUES(251,8,NULL,'2026-10-17 10:06:40.563957');
INSERT INTO "document_views" VALUES(252,8,NULL,'2026-10-28 13:22:40.563957');
INSERT INTO "document_views" VALUES(253,8,NULL,'2026-10-24 16:06:40.563957');
INSERT INTO "document_views" VALUES(254,8,NULL,'2026-10-26 11:07:40.563957');
INSERT INTO "document_views" VALUES(255,8,NULL,'2026-10-01 20:47:40.563957');
INSERT INTO "document_views" VALUES(256,8,NULL,'2026-10-19 05:09:40.563957');
INSERT INTO "document_views" VALUES(257,8,NULL,'2026-10-18 03:49:40.563957');
INSERT INTO "document_views" VALUES(258,8,NULL,'2026-10-04 00:07:40.563957');
INSERT INTO "document_views" VALUES(259,8,NULL,'2026-10-16 22:11:40.563957');
INSERT INTO "document_views" VALUES(260,8,NULL,'2026-10-16 01:51:40.563957');
INSERT INTO "document_views" VALUES(261,8,NULL,'2026-10-27 12:22:40.563957');
INSERT INTO "document_views" VALUES(262,8,NULL,'2026-10-31 07:07:40.563957');
INSERT INTO "document_views" VALUES(263,8,NULL,'2026-10-23 07:41:40.563957');
INSERT INTO "document_views" VALUES(264,8,NULL,'2026-10-17 21:16:40.563957');
INSERT INTO "document_views" VALUES(265,8,NULL,'2026-10-30 21:22:40.563957');
INSERT INTO "document_views" VALUES(266,8,NULL,'2026-10-13 07:13:40.563957');
INSERT INTO "document_views" VALUES(267,9,NULL,'2026-10-28 22:11:40.563957');
INSERT INTO "document_views" VALUES(268,9,NULL,'2026-10-10 09:52:40.563957');
INSERT INTO "document_views" VALUES(269,9,NULL,'2026-10-19 00:27:40.563957');
INSERT INTO "document_views" VALUES(270,9,NULL,'2026-10-23 12:37:40.563957');
INSERT INTO "document_views" VALUES(271,9,NULL,'2026-10-29 02:07:40.563957');
INSERT INTO "document_views" VALUES(272,9,NULL,'2026-10-06 02:21:40.563957');
INSERT INTO "document_views" VALUES(273,9,NULL,'2026-10-31 01:33:40.563957');
INSERT INTO "document_views" VALUES(274,9,NULL,'2026-10-10 10:54:40.563957');
INSERT INTO "document_views" VALUES(275,10,NULL,'2026-10-22 15:13:40.563957');
INSERT INTO "document_views" VALUES(276,10,NULL,'2026-10-14 07:19:40.563957');
INSERT INTO "document_views" VALUES(277,10,NULL,'2026-10-24 21:55:40.563957');
INSERT INTO "document_views" VALUES(278,10,NULL,'2026-10-21 14:21:40.563957');
INSERT INTO "document_views" VALUES(279,10,NULL,'2026-10-22 10:48:40.563957');
INSERT INTO "document_views" VALUES(280,10,NULL,'2026-10-30 16:28:40.563957');
INSERT INTO "document_views" VALUES(281,10,NULL,'2026-10-12 10:36:40.563957');
INSERT INTO "document_views" VALUES(282,10,NULL,'2026-10-28 04:05:40.563957');
INSERT INTO "document_views" VALUES(283,10,NULL,'2026-10-28 08:12:40.563957');
INSERT INTO "document_views" VALUES(284,10,NULL,'2026-10-08 11:34:40.563957');
INSERT INTO "document_views" VALUES(285,10,NULL,'2026-10-19 06:30:40.563957');
INSERT INTO "document_views" VALUES(286,10,NULL,'2026-10-01 08:16:40.563957');
INSERT INTO "document_views" VALUES(287,10,NULL,'2026-10-09 11:32:40.563957');
INSERT INTO "document_views" VALUES(288,10,NULL,'2026-10-31 01:14:40.563957');
INSERT INTO "document_views" VALUES(289,10,NULL,'2026-10-22 08:58:40.563957');
INSERT INTO "document_views" VALUES(290,10,NULL,'2026-10-22 21:43:40.563957');
INSERT INTO "document_views" VALUES(291,10,NULL,'2026-10-29 11:14:40.563957');
INSERT INTO "document_views" VALUES(292,10,NULL,'2026-10-23 14:25:40.563957');
INSERT INTO "document_views" VALUES(293,10,NULL,'2026-10-02 15:10:40.563957');
INSERT INTO "document_views" VALUES(294,10,NULL,'2026-10-25 19:50:40.563957');
INSERT INTO "document_views" VALUES(295,10,NULL,'2026-10-27 03:38:40.563957');
INSERT INTO "document_views" VALUES(296,10,NULL,'2026-10-07 19:57:40.563957');
INSERT INTO "document_views" VALUES(297,10,NULL,'2026-10-23 14:18:40.563957');
INSERT INTO "document_views" VALUES(298,10,NULL,'2026-10-26 17:32:40.563957');
INSERT INTO "document_views" VALUES(299,10,NULL,'2026-10-09 12:26:40.563957');
INSERT INTO "document_views" VALUES(300,10,NULL,'2026-10-31 04:12:40.563957');
INSERT INTO "document_views" VALUES(301,10,NULL,'2026-10-26 20:10:40.563957');
INSERT INTO "document_views" VALUES(302,10,NULL,'2026-10-30 17:25:40.563957');
INSERT INTO "document_views" VALUES(303,10,NULL,'2026-10-08 07:10:40.563957');
INSERT INTO "document_views" VALUES(304,10,NULL,'2026-10-15 12:41:40.563957');
INSERT INTO "document_views" VALUES(305,10,NULL,'2026-10-23 05:21:40.563957');
INSERT INTO "document_views" VALUES(306,10,NULL,'2026-10-28 18:52:40.563957');
INSERT INTO "document_views" VALUES(307,10,NULL,'2026-10-16 14:12:40.563957');
INSERT INTO "document_views" VALUES(308,10,NULL,'2026-10-17 05:27:40.563957');
INSERT INTO "document_views" VALUES(309,10,NULL,'2026-10-28 12:28:40.563957');
INSERT INTO "document_views" VALUES(310,10,NULL,'2026-10-29 21:23:40.563957');
INSERT INTO "document_views" VALUES(311,10,NULL,'2026-10-22 07:22:40.563957');
INSERT INTO "document_views" VALUES(312,10,NULL,'2026-10-22 06:13:40.563957');
INSERT INTO "document_views" VALUES(313,10,NULL,'2026-10-02 10:26:40.563957');
INSERT INTO "document_views" VALUES(314,10,NULL,'2026-10-11 01:48:40.563957');
INSERT INTO "document_views" VALUES(315,10,NULL,'2026-10-27 06:44:40.563957');
INSERT INTO "document_views" VALUES(316,10,NULL,'2026-10-20 04:02:40.563957');
INSERT INTO "document_views" VALUES(317,10,NULL,'2026-10-29 03:20:40.563957');
INSERT INTO "document_views" VALUES(318,10,NULL,'2026-10-23 03:12:40.563957');
INSERT INTO "document_views" VALUES(319,10,NULL,'2026-10-17 01:57:40.563957');
INSERT INTO "document_views" VALUES(320,10,NULL,'2026-10-21 21:15:40.563957');
INSERT INTO "document_views" VALUES(321,10,NULL,'2026-10-20 21:53:40.563957');
INSERT INTO "document_views" VALUES(322,10,NULL,'2026-10-23 14:44:40.563957');
INSERT INTO "document_views" VALUES(323,10,NULL,'2026-10-01 22:53:40.563957');
INSERT INTO "document_views" VALUES(324,10,NULL,'2026-10-23 02:16:40.563957');
INSERT INTO "document_views" VALUES(325,10,NULL,'2026-10-24 10:45:40.563957');
INSERT INTO "document_views" VALUES(326,10,NULL,'2026-10-21 02:33:40.563957');
INSERT INTO "document_views" VALUES(327,10,NULL,'2026-10-07 21:47:40.563957');
INSERT INTO "document_views" VALUES(328,10,NULL,'2026-10-11 17:03:40.563957');
INSERT INTO "document_views" VALUES(329,10,NULL,'2026-10-25 13:53:40.563957');
INSERT INTO "document_views" VALUES(330,10,NULL,'2026-10-28 07:07:40.563957');
INSERT INTO "document_views" VALUES(331,10,NULL,'2026-10-27 21:01:40.563957');
INSERT INTO "document_views" VALUES(332,10,NULL,'2026-10-08 11:25:40.563957');
INSERT INTO "document_views" VALUES(333,10,NULL,'2026-10-01 14:30:40.563957');
INSERT INTO "document_views" VALUES(334,10,NULL,'2026-10-07 15:58:40.563957');
INSERT INTO "document_views" VALUES(335,10,NULL,'2026-10-19 19:26:40.563957');
INSERT INTO "document_views" VALUES(336,10,NULL,'2026-10-25 12:40:40.563957');
INSERT INTO "document_views" VALUES(337,10,NULL,'2026-10-24 20:13:40.563957');
INSERT INTO "document_views" VALUES(338,10,NULL,'2026-10-07 07:24:40.563957');
INSERT INTO "document_views" VALUES(339,10,NULL,'2026-10-27 18:08:40.563957');
INSERT INTO "document_views" VALUES(340,10,NULL,'2026-10-28 17:11:40.563957');
INSERT INTO "document_views" VALUES(341,10,NULL,'2026-10-30 15:04:40.563957');
INSERT INTO "document_views" VALUES(342,10,NULL,'2026-10-13 18:12:40.563957');
INSERT INTO "document_views" VALUES(343,10,NULL,'2026-10-24 08:33:40.563957');
INSERT INTO "document_views" VALUES(344,10,NULL,'2026-10-10 08:57:40.563957');
INSERT INTO "document_views" VALUES(345,10,NULL,'2026-10-01 14:18:40.563957');
INSERT INTO "document_views" VALUES(346,10,NULL,'2026-10-03 02:54:40.563957');
INSERT INTO "document_views" VALUES(347,10,NULL,'2026-10-21 11:04:40.563957');
INSERT INTO "document_views" VALUES(348,10,NULL,'2026-10-26 03:47:40.563957');
INSERT INTO "document_views" VALUES(349,10,NULL,'2026-10-06 16:11:40.563957');
INSERT INTO "document_views" VALUES(350,10,NULL,'2026-10-30 15:37:40.563957');
INSERT INTO "document_views" VALUES(351,10,NULL,'2026-10-31 02:17:40.563957');
INSERT INTO "document_views" VALUES(352,10,NULL,'2026-10-23 08:52:40.563957');
INSERT INTO "document_views" VALUES(353,10,NULL,'2026-10-03 04:39:40.563957');
INSERT INTO "document_views" VALUES(354,10,NULL,'2026-10-22 22:10:40.563957');
INSERT INTO "document_views" VALUES(355,10,NULL,'2026-10-25 07:34:40.563957');
INSERT INTO "document_views" VALUES(356,10,NULL,'2026-10-25 04:28:40.563957');
INSERT INTO "document_views" VALUES(357,10,NULL,'2026-10-07 08:11:40.563957');
INSERT INTO "document_views" VALUES(358,10,NULL,'2026-10-07 18:14:40.563957');
INSERT INTO "document_views" VALUES(359,10,NULL,'2026-10-03 09:49:40.563957');
INSERT INTO "document_views" VALUES(360,10,NULL,'2026-10-13 14:33:40.563957');
INSERT INTO "document_views" VALUES(361,10,NULL,'2026-10-07 05:59:40.563957');
INSERT INTO "document_views" VALUES(362,10,NULL,'2026-10-17 23:12:40.563957');
INSERT INTO "document_views" VALUES(363,10,NULL,'2026-10-16 21:24:40.563957');
INSERT INTO "document_views" VALUES(364,10,NULL,'2026-10-02 04:07:40.563957');
INSERT INTO "document_views" VALUES(365,10,NULL,'2026-10-24 03:51:40.563957');
INSERT INTO "document_views" VALUES(366,10,NULL,'2026-10-12 03:47:40.563957');
INSERT INTO "document_views" VALUES(367,10,NULL,'2026-10-22 07:31:40.563957');
INSERT INTO "document_views" VALUES(368,10,NULL,'2026-10-27 06:13:40.563957');
INSERT INTO "document_views" VALUES(369,10,NULL,'2026-10-31 05:18:40.563957');
INSERT INTO "document_views" VALUES(370,10,NULL,'2026-10-26 18:25:40.563957');
INSERT INTO "document_views" VALUES(371,10,NULL,'2026-10-23 22:52:40.563957');
INSERT INTO "document_views" VALUES(372,10,NULL,'2026-10-20 11:53:40.563957');
INSERT INTO "document_views" VALUES(373,10,NULL,'2026-10-15 01:04:40.563957');
INSERT INTO "document_views" VALUES(374,10,NULL,'2026-10-30 04:31:40.563957');
INSERT INTO "document_views" VALUES(375,10,NULL,'2026-10-17 18:09:40.563957');
INSERT INTO "document_views" VALUES(376,10,NULL,'2026-10-17 22:59:40.563957');
INSERT INTO "document_views" VALUES(377,10,NULL,'2026-10-21 11:18:40.563957');
INSERT INTO "document_views" VALUES(378,10,NULL,'2026-10-29 15:28:40.563957');
INSERT INTO "document_views" VALUES(379,10,NULL,'2026-10-16 15:31:40.563957');
INSERT INTO "document_views" VALUES(380,10,NULL,'2026-10-28 06:53:40.563957');
INSERT INTO "document_views" VALUES(381,10,NULL,'2026-10-05 15:20:40.563957');
INSERT INTO "document_views" VALUES(382,10,NULL,'2026-10-05 08:05:40.563957');
INSERT INTO "document_views" VALUES(383,10,NULL,'2026-10-20 04:41:40.563957');
INSERT INTO "document_views" VALUES(384,10,NULL,'2026-10-22 19:25:40.563957');
INSERT INTO "document_views" VALUES(385,10,NULL,'2026-10-01 21:00:40.563957');
INSERT INTO "document_views" VALUES(386,10,NULL,'2026-10-16 16:44:40.563957');
INSERT INTO "document_views" VALUES(387,10,NULL,'2026-10-14 15:37:40.563957');
INSERT INTO "document_views" VALUES(388,10,NULL,'2026-10-09 00:25:40.563957');
INSERT INTO "document_views" VALUES(389,10,NULL,'2026-10-01 14:43:40.563957');
INSERT INTO "document_views" VALUES(390,10,NULL,'2026-10-30 18:11:40.563957');
INSERT INTO "document_views" VALUES(391,10,NULL,'2026-10-18 11:35:40.563957');
INSERT INTO "document_views" VALUES(392,10,NULL,'2026-10-26 07:20:40.563957');
INSERT INTO "document_views" VALUES(393,10,NULL,'2026-10-26 08:44:40.563957');
INSERT INTO "document_views" VALUES(394,10,NULL,'2026-10-25 06:56:40.563957');
INSERT INTO "document_views" VALUES(395,10,NULL,'2026-10-18 07:48:40.563957');
INSERT INTO "document_views" VALUES(396,10,NULL,'2026-10-11 05:32:40.563957');
INSERT INTO "document_views" VALUES(397,10,NULL,'2026-10-05 14:15:40.563957');
INSERT INTO "document_views" VALUES(398,10,NULL,'2026-10-08 21:26:40.563957');
INSERT INTO "document_views" VALUES(399,10,NULL,'2026-10-11 23:21:40.563957');
INSERT INTO "document_views" VALUES(400,10,NULL,'2026-10-17 19:11:40.563957');
INSERT INTO "document_views" VALUES(401,12,NULL,'2026-10-17 08:04:40.563957');
INSERT INTO "document_views" VALUES(402,12,NULL,'2026-10-11 08:42:40.563957');
INSERT INTO "document_views" VALUES(403,12,NULL,'2026-10-15 02:32:40.563957');
INSERT INTO "document_views" VALUES(404,12,NULL,'2026-10-16 09:47:40.563957');
INSERT INTO "document_views" VALUES(405,12,NULL,'2026-10-16 20:40:40.563957');
INSERT INTO "document_views" VALUES(406,12,NULL,'2026-10-11 06:04:40.563957');
INSERT INTO "document_views" VALUES(407,12,NULL,'2026-10-19 02:43:40.563957');
INSERT INTO "document_views" VALUES(408,12,NULL,'2026-10-30 21:08:40.563957');
INSERT INTO "document_views" VALUES(409,12,NULL,'2026-10-25 17:02:40.563957');
INSERT INTO "document_views" VALUES(410,12,NULL,'2026-10-30 02:42:40.563957');
INSERT INTO "document_views" VALUES(411,12,NULL,'2026-10-10 18:43:40.563957');
INSERT INTO "document_views" VALUES(412,12,NULL,'2026-10-20 21:54:40.563957');
INSERT INTO "document_views" VALUES(413,12,NULL,'2026-10-08 22:26:40.563957');
INSERT INTO "document_views" VALUES(414,12,NULL,'2026-10-05 14:46:40.563957');
INSERT INTO "document_views" VALUES(415,12,NULL,'2026-10-02 21:08:40.563957');
INSERT INTO "document_views" VALUES(416,12,NULL,'2026-10-12 19:39:40.563957');
INSERT INTO "document_views" VALUES(417,12,NULL,'2026-10-09 15:13:40.563957');
INSERT INTO "document_views" VALUES(418,12,NULL,'2026-10-03 02:24:40.563957');
INSERT INTO "document_views" VALUES(419,12,NULL,'2026-10-11 23:30:40.563957');
INSERT INTO "document_views" VALUES(420,12,NULL,'2026-10-07 08:11:40.563957');
INSERT INTO "document_views" VALUES(421,12,NULL,'2026-10-01 12:11:40.563957');
INSERT INTO "document_views" VALUES(422,12,NULL,'2026-10-24 17:44:40.563957');
INSERT INTO "document_views" VALUES(423,12,NULL,'2026-10-30 12:54:40.563957');
INSERT INTO "document_views" VALUES(424,12,NULL,'2026-10-29 18:38:40.563957');
INSERT INTO "document_views" VALUES(425,12,NULL,'2026-10-15 08:16:40.563957');
INSERT INTO "document_views" VALUES(426,12,NULL,'2026-10-27 18:12:40.563957');
INSERT INTO "document_views" VALUES(427,12,NULL,'2026-10-09 18:32:40.563957');
INSERT INTO "document_views" VALUES(428,12,NULL,'2026-10-30 23:14:40.563957');
INSERT INTO "document_views" VALUES(429,12,NULL,'2026-10-21 10:04:40.563957');
INSERT INTO "document_views" VALUES(430,12,NULL,'2026-10-06 12:03:40.563957');
INSERT INTO "document_views" VALUES(431,12,NULL,'2026-10-25 10:23:40.563957');
INSERT INTO "document_views" VALUES(432,12,NULL,'2026-10-29 05:03:40.563957');
INSERT INTO "document_views" VALUES(433,12,NULL,'2026-10-16 15:22:40.563957');
INSERT INTO "document_views" VALUES(434,12,NULL,'2026-10-05 20:54:40.563957');
INSERT INTO "document_views" VALUES(435,12,NULL,'2026-10-16 03:14:40.563957');
INSERT INTO "document_views" VALUES(436,12,NULL,'2026-10-30 05:56:40.563957');
INSERT INTO "document_views" VALUES(437,12,NULL,'2026-10-26 14:24:40.563957');
INSERT INTO "document_views" VALUES(438,12,NULL,'2026-10-30 23:12:40.563957');
INSERT INTO "document_views" VALUES(439,12,NULL,'2026-10-07 02:35:40.563957');
INSERT INTO "document_views" VALUES(440,12,NULL,'2026-10-24 18:33:40.563957');
INSERT INTO "document_views" VALUES(441,12,NULL,'2026-10-15 07:26:40.563957');
INSERT INTO "document_views" VALUES(442,12,NULL,'2026-10-03 16:54:40.563957');
INSERT INTO "document_views" VALUES(443,12,NULL,'2026-10-19 01:56:40.563957');
INSERT INTO "document_views" VALUES(444,12,NULL,'2026-10-06 08:51:40.563957');
INSERT INTO "document_views" VALUES(445,12,NULL,'2026-10-30 14:30:40.563957');
INSERT INTO "document_views" VALUES(446,12,NULL,'2026-10-17 21:40:40.563957');
INSERT INTO "document_views" VALUES(447,12,NULL,'2026-10-30 18:34:40.563957');
INSERT INTO "document_views" VALUES(448,12,NULL,'2026-10-28 16:02:40.563957');
INSERT INTO "document_views" VALUES(449,12,NULL,'2026-10-03 18:50:40.563957');
INSERT INTO "document_views" VALUES(450,12,NULL,'2026-10-30 07:48:40.563957');
INSERT INTO "document_views" VALUES(451,12,NULL,'2026-10-24 09:12:40.563957');
INSERT INTO "document_views" VALUES(452,12,NULL,'2026-10-25 17:37:40.563957');
INSERT INTO "document_views" VALUES(453,12,NULL,'2026-10-28 03:02:40.563957');
INSERT INTO "document_views" VALUES(454,12,NULL,'2026-10-03 15:41:40.563957');
INSERT INTO "document_views" VALUES(455,12,NULL,'2026-10-30 23:58:40.563957');
INSERT INTO "document_views" VALUES(456,12,NULL,'2026-10-16 10:50:40.563957');
INSERT INTO "document_views" VALUES(457,12,NULL,'2026-10-03 05:29:40.563957');
INSERT INTO "document_views" VALUES(458,12,NULL,'2026-10-10 22:54:40.563957');
INSERT INTO "document_views" VALUES(459,12,NULL,'2026-10-01 11:56:40.563957');
INSERT INTO "document_views" VALUES(460,12,NULL,'2026-10-28 12:17:40.563957');
INSERT INTO "document_views" VALUES(461,12,NULL,'2026-10-28 23:50:40.563957');
INSERT INTO "document_views" VALUES(462,12,NULL,'2026-10-09 23:15:40.563957');
INSERT INTO "document_views" VALUES(463,12,NULL,'2026-10-26 02:10:40.563957');
INSERT INTO "document_views" VALUES(464,12,NULL,'2026-10-10 10:52:40.563957');
INSERT INTO "document_views" VALUES(465,13,NULL,'2026-10-02 02:46:40.563957');
INSERT INTO "document_views" VALUES(466,13,NULL,'2026-10-20 01:15:40.563957');
INSERT INTO "document_views" VALUES(467,13,NULL,'2026-10-31 06:20:40.563957');
INSERT INTO "document_views" VALUES(468,13,NULL,'2026-10-29 18:59:40.563957');
INSERT INTO "document_views" VALUES(469,13,NULL,'2026-10-10 23:05:40.563957');
INSERT INTO "document_views" VALUES(470,13,NULL,'2026-10-19 06:40:40.563957');
INSERT INTO "document_views" VALUES(471,13,NULL,'2026-10-30 05:25:40.563957');
INSERT INTO "document_views" VALUES(472,13,NULL,'2026-10-29 16:50:40.563957');
INSERT INTO "document_views" VALUES(473,13,NULL,'2026-10-21 05:02:40.563957');
INSERT INTO "document_views" VALUES(474,13,NULL,'2026-10-21 18:51:40.563957');
INSERT INTO "document_views" VALUES(475,13,NULL,'2026-10-21 03:29:40.563957');
INSERT INTO "document_views" VALUES(476,13,NULL,'2026-10-22 23:39:40.563957');
INSERT INTO "document_views" VALUES(477,13,NULL,'2026-10-04 05:44:40.563957');
INSERT INTO "document_views" VALUES(478,13,NULL,'2026-10-12 08:43:40.563957');
INSERT INTO "document_views" VALUES(479,13,NULL,'2026-10-20 15:34:40.563957');
INSERT INTO "document_views" VALUES(480,13,NULL,'2026-10-17 06:09:40.563957');
INSERT INTO "document_views" VALUES(481,13,NULL,'2026-10-30 14:52:40.563957');
INSERT INTO "document_views" VALUES(482,13,NULL,'2026-10-07 16:39:40.563957');
INSERT INTO "document_views" VALUES(483,14,NULL,'2026-10-13 16:04:40.563957');
INSERT INTO "document_views" VALUES(484,14,NULL,'2026-10-31 04:27:40.563957');
INSERT INTO "document_views" VALUES(485,14,NULL,'2026-10-27 02:09:40.563957');
INSERT INTO "document_views" VALUES(486,14,NULL,'2026-10-30 21:49:40.563957');
INSERT INTO "document_views" VALUES(487,14,NULL,'2026-10-16 11:14:40.563957');
INSERT INTO "document_views" VALUES(488,14,NULL,'2026-10-19 20:07:40.563957');
INSERT INTO "document_views" VALUES(489,14,NULL,'2026-10-24 10:49:40.563957');
INSERT INTO "document_views" VALUES(490,14,NULL,'2026-10-20 15:43:40.563957');
INSERT INTO "document_views" VALUES(491,14,NULL,'2026-10-20 16:31:40.563957');
INSERT INTO "document_views" VALUES(492,15,NULL,'2026-10-30 08:52:40.563957');
INSERT INTO "document_views" VALUES(493,15,NULL,'2026-10-15 12:23:40.563957');
INSERT INTO "document_views" VALUES(494,15,NULL,'2026-10-13 23:52:40.563957');
INSERT INTO "document_views" VALUES(495,15,NULL,'2026-10-23 23:25:40.563957');
INSERT INTO "document_views" VALUES(496,15,NULL,'2026-10-23 15:44:40.563957');
INSERT INTO "document_views" VALUES(497,15,NULL,'2026-10-25 03:58:40.563957');
INSERT INTO "document_views" VALUES(498,15,NULL,'2026-10-26 20:32:40.563957');
INSERT INTO "document_views" VALUES(499,15,NULL,'2026-10-15 18:26:40.563957');
INSERT INTO "document_views" VALUES(500,15,NULL,'2026-10-03 07:46:40.563957');
INSERT INTO "document_views" VALUES(501,15,NULL,'2026-10-05 04:55:40.563957');
INSERT INTO "document_views" VALUES(502,15,NULL,'2026-10-31 04:18:40.563957');
INSERT INTO "document_views" VALUES(503,15,NULL,'2026-10-31 03:55:40.563957');
INSERT INTO "document_views" VALUES(504,15,NULL,'2026-10-12 18:29:40.563957');
INSERT INTO "document_views" VALUES(505,15,NULL,'2026-10-09 12:13:40.563957');
INSERT INTO "document_views" VALUES(506,15,NULL,'2026-10-30 12:02:40.563957');
INSERT INTO "document_views" VALUES(507,15,NULL,'2026-10-19 08:20:40.563957');
INSERT INTO "document_views" VALUES(508,15,NULL,'2026-10-29 19:08:40.563957');
INSERT INTO "document_views" VALUES(509,15,NULL,'2026-10-06 16:46:40.563957');
INSERT INTO "document_views" VALUES(510,15,NULL,'2026-10-08 05:27:40.563957');
INSERT INTO "document_views" VALUES(511,15,NULL,'2026-10-02 10:43:40.563957');
INSERT INTO "document_views" VALUES(512,15,NULL,'2026-10-27 03:40:40.563957');
INSERT INTO "document_views" VALUES(513,15,NULL,'2026-10-18 23:57:40.563957');
INSERT INTO "document_views" VALUES(514,15,NULL,'2026-10-29 14:45:40.563957');
INSERT INTO "document_views" VALUES(515,15,NULL,'2026-10-29 03:31:40.563957');
INSERT INTO "document_views" VALUES(516,15,NULL,'2026-10-25 12:13:40.563957');
INSERT INTO "document_views" VALUES(517,15,NULL,'2026-10-24 21:42:40.563957');
INSERT INTO "document_views" VALUES(518,15,NULL,'2026-10-18 16:34:40.563957');
INSERT INTO "document_views" VALUES(519,15,NULL,'2026-10-08 09:59:40.563957');
INSERT INTO "document_views" VALUES(520,15,NULL,'2026-10-17 09:16:40.563957');
INSERT INTO "document_views" VALUES(521,15,NULL,'2026-10-19 10:25:40.563957');
INSERT INTO "document_views" VALUES(522,15,NULL,'2026-10-04 07:32:40.563957');
INSERT INTO "document_views" VALUES(523,15,NULL,'2026-10-28 01:03:40.563957');
INSERT INTO "document_views" VALUES(524,15,NULL,'2026-10-27 20:40:40.563957');
INSERT INTO "document_views" VALUES(525,15,NULL,'2026-10-04 19:14:40.563957');
INSERT INTO "document_views" VALUES(526,15,NULL,'2026-10-31 02:19:40.563957');
INSERT INTO "document_views" VALUES(527,15,NULL,'2026-10-18 17:32:40.563957');
INSERT INTO "document_views" VALUES(528,15,NULL,'2026-10-30 09:36:40.563957');
INSERT INTO "document_views" VALUES(529,15,NULL,'2026-10-03 04:05:40.563957');
INSERT INTO "document_views" VALUES(530,15,NULL,'2026-10-12 23:52:40.563957');
INSERT INTO "document_views" VALUES(531,15,NULL,'2026-10-24 15:43:40.563957');
INSERT INTO "document_views" VALUES(532,15,NULL,'2026-10-25 18:35:40.563957');
INSERT INTO "document_views" VALUES(533,15,NULL,'2026-10-26 20:08:40.563957');
INSERT INTO "document_views" VALUES(534,15,NULL,'2026-10-10 11:50:40.563957');
INSERT INTO "document_views" VALUES(535,15,NULL,'2026-10-18 05:25:40.563957');
INSERT INTO "document_views" VALUES(536,15,NULL,'2026-10-29 10:07:40.563957');
INSERT INTO "document_views" VALUES(537,15,NULL,'2026-10-31 04:25:40.563957');
INSERT INTO "document_views" VALUES(538,15,NULL,'2026-10-27 08:37:40.563957');
INSERT INTO "document_views" VALUES(539,15,NULL,'2026-10-23 10:29:40.563957');
INSERT INTO "document_views" VALUES(540,15,NULL,'2026-10-22 21:53:40.563957');
INSERT INTO "document_views" VALUES(541,15,NULL,'2026-10-28 13:43:40.563957');
INSERT INTO "document_views" VALUES(542,15,NULL,'2026-10-30 16:32:40.563957');
INSERT INTO "document_views" VALUES(543,15,NULL,'2026-10-30 08:04:40.563957');
INSERT INTO "document_views" VALUES(544,15,NULL,'2026-10-14 14:36:40.563957');
INSERT INTO "document_views" VALUES(545,15,NULL,'2026-10-20 20:41:40.563957');
INSERT INTO "document_views" VALUES(546,15,NULL,'2026-10-30 17:43:40.563957');
INSERT INTO "document_views" VALUES(547,15,NULL,'2026-10-02 05:20:40.563957');
INSERT INTO "document_views" VALUES(548,15,NULL,'2026-10-30 20:55:40.563957');
INSERT INTO "document_views" VALUES(549,15,NULL,'2026-10-04 02:31:40.563957');
INSERT INTO "document_views" VALUES(550,15,NULL,'2026-10-11 21:20:40.563957');
INSERT INTO "document_views" VALUES(551,15,NULL,'2026-10-26 06:57:40.563957');
INSERT INTO "document_views" VALUES(552,15,NULL,'2026-10-21 16:31:40.563957');
INSERT INTO "document_views" VALUES(553,15,NULL,'2026-10-29 18:14:40.563957');
INSERT INTO "document_views" VALUES(554,15,NULL,'2026-10-20 23:21:40.563957');
INSERT INTO "document_views" VALUES(555,15,NULL,'2026-10-21 08:24:40.563957');
INSERT INTO "document_views" VALUES(556,15,NULL,'2026-10-10 04:45:40.563957');
INSERT INTO "document_views" VALUES(557,15,NULL,'2026-10-25 05:46:40.563957');
INSERT INTO "document_views" VALUES(558,15,NULL,'2026-10-23 15:31:40.563957');
INSERT INTO "document_views" VALUES(559,15,NULL,'2026-10-04 20:31:40.563957');
INSERT INTO "document_views" VALUES(560,15,NULL,'2026-10-18 11:38:40.563957');
INSERT INTO "document_views" VALUES(561,15,NULL,'2026-10-23 09:21:40.563957');
INSERT INTO "document_views" VALUES(562,15,NULL,'2026-10-24 03:17:40.563957');
INSERT INTO "document_views" VALUES(563,15,NULL,'2026-10-23 20:07:40.563957');
INSERT INTO "document_views" VALUES(564,15,NULL,'2026-10-29 10:07:40.563957');
INSERT INTO "document_views" VALUES(565,15,NULL,'2026-10-22 07:40:40.563957');
INSERT INTO "document_views" VALUES(566,15,NULL,'2026-10-05 04:12:40.563957');
INSERT INTO "document_views" VALUES(567,15,NULL,'2026-10-24 03:36:40.563957');
INSERT INTO "document_views" VALUES(568,15,NULL,'2026-10-27 11:06:40.563957');
INSERT INTO "document_views" VALUES(569,15,NULL,'2026-10-25 04:31:40.563957');
INSERT INTO "document_views" VALUES(570,15,NULL,'2026-10-24 20:37:40.563957');
INSERT INTO "document_views" VALUES(571,15,NULL,'2026-10-12 23:39:40.563957');
INSERT INTO "document_views" VALUES(572,15,NULL,'2026-10-26 01:28:40.563957');
INSERT INTO "document_views" VALUES(573,15,NULL,'2026-10-30 09:36:40.563957');
INSERT INTO "document_views" VALUES(574,15,NULL,'2026-10-30 13:48:40.563957');
INSERT INTO "document_views" VALUES(575,15,NULL,'2026-10-28 19:17:40.563957');
INSERT INTO "document_views" VALUES(576,15,NULL,'2026-10-25 09:11:40.563957');
INSERT INTO "document_views" VALUES(577,15,NULL,'2026-10-09 23:09:40.563957');
INSERT INTO "document_views" VALUES(578,15,NULL,'2026-10-30 22:28:40.563957');
INSERT INTO "document_views" VALUES(579,15,NULL,'2026-10-28 10:39:40.563957');
INSERT INTO "document_views" VALUES(580,15,NULL,'2026-10-29 08:50:40.563957');
INSERT INTO "document_views" VALUES(581,15,NULL,'2026-10-30 09:46:40.563957');
INSERT INTO "document_views" VALUES(582,15,NULL,'2026-10-21 11:58:40.563957');
INSERT INTO "document_views" VALUES(583,15,NULL,'2026-10-11 15:53:40.563957');
INSERT INTO "document_views" VALUES(584,15,NULL,'2026-10-14 11:56:40.563957');
INSERT INTO "document_views" VALUES(585,15,NULL,'2026-10-16 09:53:40.563957');
INSERT INTO "document_views" VALUES(586,15,NULL,'2026-10-26 09:48:40.563957');
INSERT INTO "document_views" VALUES(587,15,NULL,'2026-10-26 16:12:40.563957');
INSERT INTO "document_views" VALUES(588,16,NULL,'2026-10-16 21:50:40.563957');
INSERT INTO "document_views" VALUES(589,16,NULL,'2026-10-18 19:12:40.563957');
INSERT INTO "document_views" VALUES(590,16,NULL,'2026-10-20 20:37:40.563957');
INSERT INTO "document_views" VALUES(591,16,NULL,'2026-10-23 05:55:40.563957');
INSERT INTO "document_views" VALUES(592,16,NULL,'2026-10-30 21:25:40.563957');
INSERT INTO "document_views" VALUES(593,16,NULL,'2026-10-31 04:08:40.563957');
INSERT INTO "document_views" VALUES(594,16,NULL,'2026-10-17 13:54:40.563957');
INSERT INTO "document_views" VALUES(595,16,NULL,'2026-10-24 11:24:40.563957');
INSERT INTO "document_views" VALUES(596,16,NULL,'2026-10-20 05:48:40.563957');
INSERT INTO "document_views" VALUES(597,16,NULL,'2026-10-22 11:42:40.563957');
INSERT INTO "document_views" VALUES(598,16,NULL,'2026-10-15 20:14:40.563957');
INSERT INTO "document_views" VALUES(599,16,NULL,'2026-10-17 14:06:40.563957');
INSERT INTO "document_views" VALUES(600,16,NULL,'2026-10-30 05:06:40.563957');
INSERT INTO "document_views" VALUES(601,16,NULL,'2026-10-22 19:29:40.563957');
INSERT INTO "document_views" VALUES(602,16,NULL,'2026-10-02 04:20:40.563957');
INSERT INTO "document_views" VALUES(603,16,NULL,'2026-10-21 01:19:40.563957');
INSERT INTO "document_views" VALUES(604,16,NULL,'2026-10-30 16:16:40.563957');
INSERT INTO "document_views" VALUES(605,16,NULL,'2026-10-01 13:19:40.563957');
INSERT INTO "document_views" VALUES(606,16,NULL,'2026-10-21 01:47:40.563957');
INSERT INTO "document_views" VALUES(607,16,NULL,'2026-10-25 21:33:40.563957');
INSERT INTO "document_views" VALUES(608,16,NULL,'2026-10-24 19:40:40.563957');
INSERT INTO "document_views" VALUES(609,16,NULL,'2026-10-15 05:25:40.563957');
INSERT INTO "document_views" VALUES(610,16,NULL,'2026-10-10 09:07:40.563957');
INSERT INTO "document_views" VALUES(611,16,NULL,'2026-10-25 19:57:40.563957');
INSERT INTO "document_views" VALUES(612,16,NULL,'2026-10-30 08:03:40.563957');
INSERT INTO "document_views" VALUES(613,16,NULL,'2026-10-24 22:36:40.563957');
INSERT INTO "document_views" VALUES(614,16,NULL,'2026-10-13 08:48:40.563957');
INSERT INTO "document_views" VALUES(615,16,NULL,'2026-10-02 10:38:40.563957');
INSERT INTO "document_views" VALUES(616,16,NULL,'2026-10-06 19:50:40.563957');
INSERT INTO "document_views" VALUES(617,16,NULL,'2026-10-30 08:33:40.563957');
INSERT INTO "document_views" VALUES(618,16,NULL,'2026-10-29 19:16:40.563957');
INSERT INTO "document_views" VALUES(619,16,NULL,'2026-10-26 08:49:40.563957');
INSERT INTO "document_views" VALUES(620,16,NULL,'2026-10-14 17:50:40.563957');
INSERT INTO "document_views" VALUES(621,16,NULL,'2026-10-30 04:19:40.563957');
INSERT INTO "document_views" VALUES(622,16,NULL,'2026-10-26 18:21:40.563957');
INSERT INTO "document_views" VALUES(623,16,NULL,'2026-10-16 20:00:40.563957');
INSERT INTO "document_views" VALUES(624,16,NULL,'2026-10-09 08:20:40.563957');
INSERT INTO "document_views" VALUES(625,16,NULL,'2026-10-13 07:49:40.563957');
INSERT INTO "document_views" VALUES(626,17,NULL,'2026-10-15 13:51:40.563957');
INSERT INTO "document_views" VALUES(627,17,NULL,'2026-10-25 18:50:40.563957');
INSERT INTO "document_views" VALUES(628,17,NULL,'2026-10-26 23:54:40.563957');
INSERT INTO "document_views" VALUES(629,17,NULL,'2026-10-25 14:37:40.563957');
INSERT INTO "document_views" VALUES(630,17,NULL,'2026-10-29 02:31:40.563957');
INSERT INTO "document_views" VALUES(631,17,NULL,'2026-10-29 21:07:40.563957');
INSERT INTO "document_views" VALUES(632,17,NULL,'2026-10-09 03:45:40.563957');
INSERT INTO "document_views" VALUES(633,17,NULL,'2026-10-20 12:47:40.563957');
INSERT INTO "document_views" VALUES(634,17,NULL,'2026-10-08 13:14:40.563957');
INSERT INTO "document_views" VALUES(635,18,NULL,'2026-10-06 10:07:40.563957');
INSERT INTO "document_views" VALUES(636,18,NULL,'2026-10-29 18:21:40.563957');
INSERT INTO "document_views" VALUES(637,18,NULL,'2026-10-30 01:02:40.563957');
INSERT INTO "document_views" VALUES(638,18,NULL,'2026-10-08 09:53:40.563957');
INSERT INTO "document_views" VALUES(639,18,NULL,'2026-10-10 01:33:40.563957');
INSERT INTO "document_views" VALUES(640,18,NULL,'2026-10-14 05:43:40.563957');
INSERT INTO "document_views" VALUES(641,18,NULL,'2026-10-23 08:07:40.563957');
INSERT INTO "document_views" VALUES(642,18,NULL,'2026-10-13 16:03:40.563957');
INSERT INTO "document_views" VALUES(643,18,NULL,'2026-10-17 15:53:40.563957');
INSERT INTO "document_views" VALUES(644,18,NULL,'2026-10-28 23:03:40.563957');
INSERT INTO "document_views" VALUES(645,18,NULL,'2026-10-26 15:12:40.563957');
INSERT INTO "document_views" VALUES(646,18,NULL,'2026-10-06 00:35:40.563957');
INSERT INTO "document_views" VALUES(647,18,NULL,'2026-10-24 11:44:40.563957');
INSERT INTO "document_views" VALUES(648,18,NULL,'2026-10-01 15:27:40.563957');
INSERT INTO "document_views" VALUES(649,18,NULL,'2026-10-11 18:10:40.563957');
INSERT INTO "document_views" VALUES(650,18,NULL,'2026-10-21 16:55:40.563957');
INSERT INTO "document_views" VALUES(651,18,NULL,'2026-10-03 00:24:40.563957');
INSERT INTO "document_views" VALUES(652,18,NULL,'2026-10-10 02:29:40.563957');
INSERT INTO "document_views" VALUES(653,18,NULL,'2026-10-07 05:26:40.563957');
INSERT INTO "document_views" VALUES(654,18,NULL,'2026-10-16 18:32:40.563957');
INSERT INTO "document_views" VALUES(655,18,NULL,'2026-10-20 03:42:40.563957');
INSERT INTO "document_views" VALUES(656,18,NULL,'2026-10-13 13:36:40.563957');
INSERT INTO "document_views" VALUES(657,18,NULL,'2026-10-07 21:29:40.563957');
INSERT INTO "document_views" VALUES(658,18,NULL,'2026-10-31 01:44:40.563957');
INSERT INTO "document_views" VALUES(659,18,NULL,'2026-10-27 13:41:40.563957');
INSERT INTO "document_views" VALUES(660,18,NULL,'2026-10-29 16:17:40.563957');
INSERT INTO "document_views" VALUES(661,18,NULL,'2026-10-30 23:38:40.563957');
INSERT INTO "document_views" VALUES(662,18,NULL,'2026-10-09 19:17:40.563957');
INSERT INTO "document_views" VALUES(663,18,NULL,'2026-10-04 17:03:40.563957');
INSERT INTO "document_views" VALUES(664,18,NULL,'2026-10-30 14:04:40.563957');
INSERT INTO "document_views" VALUES(665,18,NULL,'2026-10-24 18:02:40.563957');
INSERT INTO "document_views" VALUES(666,18,NULL,'2026-10-01 18:25:40.563957');
INSERT INTO "document_views" VALUES(667,18,NULL,'2026-10-28 20:20:40.563957');
INSERT INTO "document_views" VALUES(668,18,NULL,'2026-10-04 09:01:40.563957');
INSERT INTO "document_views" VALUES(669,18,NULL,'2026-10-26 02:13:40.563957');
INSERT INTO "document_views" VALUES(670,18,NULL,'2026-10-29 21:25:40.563957');
INSERT INTO "document_views" VALUES(671,18,NULL,'2026-10-04 15:05:40.563957');
INSERT INTO "document_views" VALUES(672,18,NULL,'2026-10-15 02:28:40.563957');
INSERT INTO "document_views" VALUES(673,18,NULL,'2026-10-11 15:12:40.563957');
INSERT INTO "document_views" VALUES(674,18,NULL,'2026-10-23 07:02:40.563957');
INSERT INTO "document_views" VALUES(675,18,NULL,'2026-10-06 06:34:40.563957');
INSERT INTO "document_views" VALUES(676,18,NULL,'2026-10-28 02:06:40.563957');
INSERT INTO "document_views" VALUES(677,18,NULL,'2026-10-19 10:26:40.563957');
INSERT INTO "document_views" VALUES(678,18,NULL,'2026-10-21 03:25:40.563957');
INSERT INTO "document_views" VALUES(679,18,NULL,'2026-10-10 23:06:40.563957');
INSERT INTO "document_views" VALUES(680,18,NULL,'2026-10-27 05:35:40.563957');
INSERT INTO "document_views" VALUES(681,18,NULL,'2026-10-27 09:24:40.563957');
INSERT INTO "document_views" VALUES(682,18,NULL,'2026-10-10 15:36:40.563957');
INSERT INTO "document_views" VALUES(683,18,NULL,'2026-10-30 14:09:40.563957');
INSERT INTO "document_views" VALUES(684,18,NULL,'2026-10-18 06:39:40.563957');
INSERT INTO "document_views" VALUES(685,18,NULL,'2026-10-16 11:35:40.563957');
INSERT INTO "document_views" VALUES(686,18,NULL,'2026-10-28 02:18:40.563957');
INSERT INTO "document_views" VALUES(687,18,NULL,'2026-10-27 07:09:40.563957');
INSERT INTO "document_views" VALUES(688,18,NULL,'2026-10-17 23:00:40.563957');
INSERT INTO "document_views" VALUES(689,18,NULL,'2026-10-19 00:49:40.563957');
INSERT INTO "document_views" VALUES(690,18,NULL,'2026-10-16 04:17:40.563957');
INSERT INTO "document_views" VALUES(691,18,NULL,'2026-10-20 18:54:40.563957');
INSERT INTO "document_views" VALUES(692,18,NULL,'2026-10-30 13:15:40.563957');
INSERT INTO "document_views" VALUES(693,18,NULL,'2026-10-19 13:53:40.563957');
INSERT INTO "document_views" VALUES(694,18,NULL,'2026-10-19 17:53:40.563957');
INSERT INTO "document_views" VALUES(695,18,NULL,'2026-10-07 05:43:40.563957');
INSERT INTO "document_views" VALUES(696,18,NULL,'2026-10-16 18:28:40.563957');
INSERT INTO "document_views" VALUES(697,18,NULL,'2026-10-28 06:39:40.563957');
INSERT INTO "document_views" VALUES(698,18,NULL,'2026-10-26 04:54:40.563957');
INSERT INTO "document_views" VALUES(699,18,NULL,'2026-10-25 08:47:40.563957');
INSERT INTO "document_views" VALUES(700,18,NULL,'2026-10-16 11:21:40.563957');
INSERT INTO "document_views" VALUES(701,18,NULL,'2026-10-12 19:52:40.563957');
INSERT INTO "document_views" VALUES(702,18,NULL,'2026-10-29 19:11:40.563957');
INSERT INTO "document_views" VALUES(703,18,NULL,'2026-10-19 09:16:40.563957');
INSERT INTO "document_views" VALUES(704,19,NULL,'2026-10-14 07:28:40.563957');
INSERT INTO "document_views" VALUES(705,19,NULL,'2026-10-22 00:59:40.563957');
INSERT INTO "document_views" VALUES(706,19,NULL,'2026-10-10 05:03:40.563957');
INSERT INTO "document_views" VALUES(707,19,NULL,'2026-10-13 15:35:40.563957');
INSERT INTO "document_views" VALUES(708,19,NULL,'2026-10-31 00:20:40.563957');
INSERT INTO "document_views" VALUES(709,19,NULL,'2026-10-31 00:24:40.563957');
INSERT INTO "document_views" VALUES(710,19,NULL,'2026-10-06 20:26:40.563957');
INSERT INTO "document_views" VALUES(711,19,NULL,'2026-10-04 13:37:40.563957');
INSERT INTO "document_views" VALUES(712,19,NULL,'2026-10-24 12:40:40.563957');
INSERT INTO "document_views" VALUES(713,19,NULL,'2026-10-22 05:58:40.563957');
INSERT INTO "document_views" VALUES(714,19,NULL,'2026-10-12 00:41:40.563957');
INSERT INTO "document_views" VALUES(715,19,NULL,'2026-10-27 05:35:40.563957');
INSERT INTO "document_views" VALUES(716,19,NULL,'2026-10-07 19:53:40.563957');
INSERT INTO "document_views" VALUES(717,19,NULL,'2026-10-27 18:39:40.563957');
INSERT INTO "document_views" VALUES(718,19,NULL,'2026-10-23 17:33:40.563957');
INSERT INTO "document_views" VALUES(719,19,NULL,'2026-10-12 18:01:40.563957');
INSERT INTO "document_views" VALUES(720,19,NULL,'2026-10-26 00:50:40.563957');
INSERT INTO "document_views" VALUES(721,19,NULL,'2026-10-21 14:14:40.563957');
INSERT INTO "document_views" VALUES(722,19,NULL,'2026-10-24 13:29:40.563957');
INSERT INTO "document_views" VALUES(723,19,NULL,'2026-10-28 04:23:40.563957');
INSERT INTO "document_views" VALUES(724,19,NULL,'2026-10-13 04:31:40.563957');
INSERT INTO "document_views" VALUES(725,19,NULL,'2026-10-24 01:03:40.563957');
INSERT INTO "document_views" VALUES(726,19,NULL,'2026-10-19 20:15:40.563957');
INSERT INTO "document_views" VALUES(727,19,NULL,'2026-10-30 20:01:40.563957');
INSERT INTO "document_views" VALUES(728,19,NULL,'2026-10-15 20:45:40.563957');
INSERT INTO "document_views" VALUES(729,19,NULL,'2026-10-22 16:40:40.563957');
INSERT INTO "document_views" VALUES(730,19,NULL,'2026-10-29 16:03:40.563957');
INSERT INTO "document_views" VALUES(731,19,NULL,'2026-10-26 05:46:40.563957');
INSERT INTO "document_views" VALUES(732,19,NULL,'2026-10-12 19:10:40.563957');
INSERT INTO "document_views" VALUES(733,19,NULL,'2026-10-17 16:22:40.563957');
INSERT INTO "document_views" VALUES(734,19,NULL,'2026-10-28 05:15:40.563957');
INSERT INTO "document_views" VALUES(735,19,NULL,'2026-10-30 09:27:40.563957');
INSERT INTO "document_views" VALUES(736,19,NULL,'2026-10-23 13:42:40.563957');
INSERT INTO "document_views" VALUES(737,19,NULL,'2026-10-09 08:01:40.563957');
INSERT INTO "document_views" VALUES(738,19,NULL,'2026-10-30 06:09:40.563957');
INSERT INTO "document_views" VALUES(739,19,NULL,'2026-10-29 10:28:40.563957');
INSERT INTO "document_views" VALUES(740,19,NULL,'2026-10-14 16:15:40.563957');
INSERT INTO "document_views" VALUES(741,19,NULL,'2026-10-31 04:55:40.563957');
INSERT INTO "document_views" VALUES(742,19,NULL,'2026-10-28 09:11:40.563957');
INSERT INTO "document_views" VALUES(743,19,NULL,'2026-10-24 18:08:40.563957');
INSERT INTO "document_views" VALUES(744,19,NULL,'2026-10-04 06:06:40.563957');
INSERT INTO "document_views" VALUES(745,19,NULL,'2026-10-17 08:02:40.563957');
INSERT INTO "document_views" VALUES(746,19,NULL,'2026-10-22 18:33:40.563957');
INSERT INTO "document_views" VALUES(747,19,NULL,'2026-10-25 04:35:40.563957');
INSERT INTO "document_views" VALUES(748,19,NULL,'2026-10-18 13:08:40.563957');
INSERT INTO "document_views" VALUES(749,19,NULL,'2026-10-24 20:29:40.563957');
INSERT INTO "document_views" VALUES(750,19,NULL,'2026-10-15 22:41:40.563957');
INSERT INTO "document_views" VALUES(751,19,NULL,'2026-10-03 06:19:40.563957');
INSERT INTO "document_views" VALUES(752,19,NULL,'2026-10-12 14:10:40.563957');
INSERT INTO "document_views" VALUES(753,19,NULL,'2026-10-20 12:02:40.563957');
INSERT INTO "document_views" VALUES(754,19,NULL,'2026-10-30 22:19:40.563957');
INSERT INTO "document_views" VALUES(755,19,NULL,'2026-10-13 23:53:40.563957');
INSERT INTO "document_views" VALUES(756,19,NULL,'2026-10-01 21:28:40.563957');
INSERT INTO "document_views" VALUES(757,19,NULL,'2026-10-14 14:27:40.563957');
INSERT INTO "document_views" VALUES(758,19,NULL,'2026-10-29 02:35:40.563957');
INSERT INTO "document_views" VALUES(759,19,NULL,'2026-10-07 15:47:40.563957');
INSERT INTO "document_views" VALUES(760,19,NULL,'2026-10-29 16:01:40.563957');
INSERT INTO "document_views" VALUES(761,19,NULL,'2026-10-01 07:56:40.563957');
INSERT INTO "document_views" VALUES(762,19,NULL,'2026-10-02 20:18:40.563957');
INSERT INTO "document_views" VALUES(763,19,NULL,'2026-10-16 05:00:40.563957');
INSERT INTO "document_views" VALUES(764,19,NULL,'2026-10-19 21:18:40.563957');
INSERT INTO "document_views" VALUES(765,19,NULL,'2026-10-07 01:50:40.563957');
INSERT INTO "document_views" VALUES(766,19,NULL,'2026-10-13 07:18:40.563957');
INSERT INTO "document_views" VALUES(767,19,NULL,'2026-10-16 18:52:40.563957');
INSERT INTO "document_views" VALUES(768,19,NULL,'2026-10-21 03:04:40.563957');
INSERT INTO "document_views" VALUES(769,19,NULL,'2026-10-02 02:28:40.563957');
INSERT INTO "document_views" VALUES(770,19,NULL,'2026-10-28 14:21:40.563957');
INSERT INTO "document_views" VALUES(771,19,NULL,'2026-10-30 12:18:40.563957');
INSERT INTO "document_views" VALUES(772,19,NULL,'2026-10-18 15:15:40.563957');
INSERT INTO "document_views" VALUES(773,19,NULL,'2026-10-09 12:23:40.563957');
INSERT INTO "document_views" VALUES(774,19,NULL,'2026-10-30 04:16:40.563957');
INSERT INTO "document_views" VALUES(775,19,NULL,'2026-10-30 17:37:40.563957');
INSERT INTO "document_views" VALUES(776,19,NULL,'2026-10-01 14:52:40.563957');
INSERT INTO "document_views" VALUES(777,19,NULL,'2026-10-20 17:14:40.563957');
INSERT INTO "document_views" VALUES(778,19,NULL,'2026-10-10 04:41:40.563957');
INSERT INTO "document_views" VALUES(779,19,NULL,'2026-10-29 20:23:40.563957');
INSERT INTO "document_views" VALUES(780,19,NULL,'2026-10-16 15:51:40.563957');
INSERT INTO "document_views" VALUES(781,19,NULL,'2026-10-22 13:33:40.563957');
INSERT INTO "document_views" VALUES(782,19,NULL,'2026-10-25 12:23:40.563957');
INSERT INTO "document_views" VALUES(783,19,NULL,'2026-10-17 01:00:40.563957');
INSERT INTO "document_views" VALUES(784,19,NULL,'2026-10-12 02:48:40.563957');
INSERT INTO "document_views" VALUES(785,19,NULL,'2026-10-24 05:19:40.563957');
INSERT INTO "document_views" VALUES(786,19,NULL,'2026-10-08 13:31:40.563957');
INSERT INTO "document_views" VALUES(787,19,NULL,'2026-10-30 01:35:40.563957');
INSERT INTO "document_views" VALUES(788,19,NULL,'2026-10-29 23:31:40.563957');
INSERT INTO "document_views" VALUES(789,19,NULL,'2026-10-25 13:30:40.563957');
INSERT INTO "document_views" VALUES(790,19,NULL,'2026-10-06 04:31:40.563957');
INSERT INTO "document_views" VALUES(791,19,NULL,'2026-10-27 09:32:40.563957');
INSERT INTO "document_views" VALUES(792,19,NULL,'2026-10-03 21:50:40.563957');
INSERT INTO "document_views" VALUES(793,19,NULL,'2026-10-29 20:52:40.563957');
INSERT INTO "document_views" VALUES(794,19,NULL,'2026-10-18 04:01:40.563957');
INSERT INTO "document_views" VALUES(795,19,NULL,'2026-10-22 01:27:40.563957');
INSERT INTO "document_views" VALUES(796,19,NULL,'2026-10-18 11:23:40.563957');
INSERT INTO "document_views" VALUES(797,19,NULL,'2026-10-29 08:43:40.563957');
INSERT INTO "document_views" VALUES(798,19,NULL,'2026-10-16 10:33:40.563957');
INSERT INTO "document_views" VALUES(799,19,NULL,'2026-10-25 11:58:40.563957');
INSERT INTO "document_views" VALUES(800,19,NULL,'2026-10-31 06:14:40.563957');
INSERT INTO "document_views" VALUES(801,19,NULL,'2026-10-30 09:19:40.563957');
INSERT INTO "document_views" VALUES(802,19,NULL,'2026-10-11 22:10:40.563957');
INSERT INTO "document_views" VALUES(803,19,NULL,'2026-10-15 11:41:40.563957');
INSERT INTO "document_views" VALUES(804,19,NULL,'2026-10-23 09:24:40.563957');
INSERT INTO "document_views" VALUES(805,19,NULL,'2026-10-30 09:48:40.563957');
INSERT INTO "document_views" VALUES(806,19,NULL,'2026-10-19 09:18:40.563957');
INSERT INTO "document_views" VALUES(807,19,NULL,'2026-10-03 14:43:40.563957');
INSERT INTO "document_views" VALUES(808,20,NULL,'2026-10-14 21:03:40.563957');
INSERT INTO "document_views" VALUES(809,20,NULL,'2026-10-22 07:42:40.563957');
INSERT INTO "document_views" VALUES(810,20,NULL,'2026-10-30 16:12:40.563957');
INSERT INTO "document_views" VALUES(811,20,NULL,'2026-10-23 15:21:40.563957');
INSERT INTO "document_views" VALUES(812,20,NULL,'2026-10-28 10:30:40.563957');
INSERT INTO "document_views" VALUES(813,20,NULL,'2026-10-29 20:19:40.563957');
INSERT INTO "document_views" VALUES(814,20,NULL,'2026-10-12 19:25:40.563957');
INSERT INTO "document_views" VALUES(815,20,NULL,'2026-10-03 02:45:40.563957');
INSERT INTO "document_views" VALUES(816,20,NULL,'2026-10-11 13:38:40.563957');
INSERT INTO "document_views" VALUES(817,20,NULL,'2026-10-19 20:19:40.563957');
INSERT INTO "document_views" VALUES(818,20,NULL,'2026-10-28 03:02:40.563957');
INSERT INTO "document_views" VALUES(819,20,NULL,'2026-10-27 22:45:40.563957');
INSERT INTO "document_views" VALUES(820,20,NULL,'2026-10-30 05:29:40.563957');
INSERT INTO "document_views" VALUES(821,20,NULL,'2026-10-26 18:06:40.563957');
INSERT INTO "document_views" VALUES(822,20,NULL,'2026-10-07 16:56:40.563957');
INSERT INTO "document_views" VALUES(823,20,NULL,'2026-10-28 01:45:40.563957');
INSERT INTO "document_views" VALUES(824,20,NULL,'2026-10-09 11:29:40.563957');
INSERT INTO "document_views" VALUES(825,20,NULL,'2026-10-14 00:44:40.563957');
INSERT INTO "document_views" VALUES(826,20,NULL,'2026-10-11 14:12:40.563957');
INSERT INTO "document_views" VALUES(827,20,NULL,'2026-10-01 15:16:40.563957');
INSERT INTO "document_views" VALUES(828,20,NULL,'2026-10-21 20:41:40.563957');
INSERT INTO "document_views" VALUES(829,20,NULL,'2026-10-22 04:08:40.563957');
INSERT INTO "document_views" VALUES(830,20,NULL,'2026-10-03 13:57:40.563957');
INSERT INTO "document_views" VALUES(831,20,NULL,'2026-10-22 22:59:40.563957');
INSERT INTO "document_views" VALUES(832,20,NULL,'2026-10-28 19:10:40.563957');
INSERT INTO "document_views" VALUES(833,20,NULL,'2026-10-30 21:36:40.563957');
INSERT INTO "document_views" VALUES(834,20,NULL,'2026-10-21 08:53:40.563957');
INSERT INTO "document_views" VALUES(835,20,NULL,'2026-10-15 21:27:40.563957');
INSERT INTO "document_views" VALUES(836,20,NULL,'2026-10-20 03:32:40.563957');
INSERT INTO "document_views" VALUES(837,20,NULL,'2026-10-23 22:11:40.563957');
INSERT INTO "document_views" VALUES(838,20,NULL,'2026-10-12 17:27:40.563957');
INSERT INTO "document_views" VALUES(839,20,NULL,'2026-10-24 17:32:40.563957');
INSERT INTO "document_views" VALUES(840,20,NULL,'2026-10-30 12:02:40.563957');
INSERT INTO "document_views" VALUES(841,20,NULL,'2026-10-28 12:19:40.563957');
INSERT INTO "document_views" VALUES(842,20,NULL,'2026-10-26 18:01:40.563957');
INSERT INTO "document_views" VALUES(843,20,NULL,'2026-10-20 12:26:40.563957');
INSERT INTO "document_views" VALUES(844,20,NULL,'2026-10-27 09:56:40.563957');
INSERT INTO "document_views" VALUES(845,20,NULL,'2026-10-15 03:09:40.563957');
INSERT INTO "document_views" VALUES(846,20,NULL,'2026-10-30 03:54:40.563957');
INSERT INTO "document_views" VALUES(847,20,NULL,'2026-10-24 19:38:40.563957');
INSERT INTO "document_views" VALUES(848,20,NULL,'2026-10-19 18:44:40.563957');
INSERT INTO "document_views" VALUES(849,20,NULL,'2026-10-12 00:25:40.563957');
INSERT INTO "document_views" VALUES(850,20,NULL,'2026-10-17 17:30:40.563957');
INSERT INTO "document_views" VALUES(851,20,NULL,'2026-10-22 05:40:40.563957');
INSERT INTO "document_views" VALUES(852,20,NULL,'2026-10-30 19:50:40.563957');
INSERT INTO "document_views" VALUES(853,20,NULL,'2026-10-09 13:29:40.563957');
INSERT INTO "document_views" VALUES(854,20,NULL,'2026-10-22 10:31:40.563957');
INSERT INTO "document_views" VALUES(855,20,NULL,'2026-10-06 02:26:40.563957');
INSERT INTO "document_views" VALUES(856,20,NULL,'2026-10-25 10:17:40.563957');
INSERT INTO "document_views" VALUES(857,20,NULL,'2026-10-26 17:48:40.563957');
INSERT INTO "document_views" VALUES(858,20,NULL,'2026-10-01 21:00:40.563957');
INSERT INTO "document_views" VALUES(859,20,NULL,'2026-10-17 13:54:40.563957');
INSERT INTO "document_views" VALUES(860,20,NULL,'2026-10-08 13:02:40.563957');
INSERT INTO "document_views" VALUES(861,20,NULL,'2026-10-21 12:00:40.563957');
INSERT INTO "document_views" VALUES(862,20,NULL,'2026-10-27 06:38:40.563957');
INSERT INTO "document_views" VALUES(863,20,NULL,'2026-10-24 08:13:40.563957');
INSERT INTO "document_views" VALUES(864,20,NULL,'2026-10-30 16:59:40.563957');
INSERT INTO "document_views" VALUES(865,20,NULL,'2026-10-18 07:43:40.563957');
INSERT INTO "document_views" VALUES(866,20,NULL,'2026-10-16 10:50:40.563957');
INSERT INTO "document_views" VALUES(867,20,NULL,'2026-10-21 08:50:40.563957');
INSERT INTO "document_views" VALUES(868,20,NULL,'2026-10-10 11:28:40.563957');
INSERT INTO "document_views" VALUES(869,20,NULL,'2026-10-19 05:27:40.563957');
INSERT INTO "document_views" VALUES(870,20,NULL,'2026-10-19 01:23:40.563957');
INSERT INTO "document_views" VALUES(871,20,NULL,'2026-10-20 10:03:40.563957');
INSERT INTO "document_views" VALUES(872,20,NULL,'2026-10-11 18:14:40.563957');
INSERT INTO "document_views" VALUES(873,20,NULL,'2026-10-29 07:58:40.563957');
INSERT INTO "document_views" VALUES(874,20,NULL,'2026-10-27 11:40:40.563957');
INSERT INTO "document_views" VALUES(875,20,NULL,'2026-10-04 03:27:40.563957');
INSERT INTO "document_views" VALUES(876,20,NULL,'2026-10-28 16:09:40.563957');
INSERT INTO "document_views" VALUES(877,20,NULL,'2026-10-27 02:02:40.563957');
INSERT INTO "document_views" VALUES(878,20,NULL,'2026-10-24 00:15:40.563957');
INSERT INTO "document_views" VALUES(879,20,NULL,'2026-10-23 10:20:40.563957');
INSERT INTO "document_views" VALUES(880,20,NULL,'2026-10-05 05:05:40.563957');
INSERT INTO "document_views" VALUES(881,20,NULL,'2026-10-13 13:30:40.563957');
INSERT INTO "document_views" VALUES(882,20,NULL,'2026-10-28 20:07:40.563957');
INSERT INTO "document_views" VALUES(883,20,NULL,'2026-10-01 14:53:40.563957');
INSERT INTO "document_views" VALUES(884,20,NULL,'2026-10-20 20:30:40.563957');
INSERT INTO "document_views" VALUES(885,20,NULL,'2026-10-03 15:31:40.563957');
INSERT INTO "document_views" VALUES(886,20,NULL,'2026-10-05 19:31:40.563957');
INSERT INTO "document_views" VALUES(887,20,NULL,'2026-10-19 08:08:40.563957');
INSERT INTO "document_views" VALUES(888,20,NULL,'2026-10-11 07:58:40.563957');
INSERT INTO "document_views" VALUES(889,20,NULL,'2026-10-16 07:33:40.563957');
INSERT INTO "document_views" VALUES(890,20,NULL,'2026-10-27 14:41:40.563957');
INSERT INTO "document_views" VALUES(891,20,NULL,'2026-10-28 22:48:40.563957');
INSERT INTO "document_views" VALUES(892,20,NULL,'2026-10-27 21:01:40.563957');
INSERT INTO "document_views" VALUES(893,20,NULL,'2026-10-28 21:03:40.563957');
INSERT INTO "document_views" VALUES(894,20,NULL,'2026-10-12 00:08:40.563957');
INSERT INTO "document_views" VALUES(895,20,NULL,'2026-10-14 14:31:40.563957');
INSERT INTO "document_views" VALUES(896,20,NULL,'2026-10-26 19:18:40.563957');
INSERT INTO "document_views" VALUES(897,20,NULL,'2026-10-19 21:52:40.563957');
INSERT INTO "document_views" VALUES(898,20,NULL,'2026-10-26 11:38:40.563957');
INSERT INTO "document_views" VALUES(899,20,NULL,'2026-10-14 18:15:40.563957');
INSERT INTO "document_views" VALUES(900,20,NULL,'2026-10-05 17:44:40.563957');
INSERT INTO "document_views" VALUES(901,20,NULL,'2026-10-10 02:13:40.563957');
INSERT INTO "document_views" VALUES(902,20,NULL,'2026-10-26 21:23:40.563957');
INSERT INTO "document_views" VALUES(903,20,NULL,'2026-10-04 04:31:40.563957');
INSERT INTO "document_views" VALUES(904,20,NULL,'2026-10-25 16:07:40.563957');
INSERT INTO "document_views" VALUES(905,20,NULL,'2026-10-15 14:51:40.563957');
INSERT INTO "document_views" VALUES(906,21,NULL,'2026-10-19 12:01:40.563957');
INSERT INTO "document_views" VALUES(907,21,NULL,'2026-10-15 02:31:40.563957');
INSERT INTO "document_views" VALUES(908,21,NULL,'2026-10-30 11:11:40.563957');
INSERT INTO "document_views" VALUES(909,21,NULL,'2026-10-28 05:29:40.563957');
INSERT INTO "document_views" VALUES(910,21,NULL,'2026-10-15 13:05:40.563957');
INSERT INTO "document_views" VALUES(911,21,NULL,'2026-10-28 23:16:40.563957');
INSERT INTO "document_views" VALUES(912,21,NULL,'2026-10-30 17:06:40.563957');
INSERT INTO "document_views" VALUES(913,21,NULL,'2026-10-25 15:05:40.563957');
INSERT INTO "document_views" VALUES(914,21,NULL,'2026-10-31 02:31:40.563957');
INSERT INTO "document_views" VALUES(915,21,NULL,'2026-10-30 12:25:40.563957');
INSERT INTO "document_views" VALUES(916,21,NULL,'2026-10-03 01:49:40.563957');
INSERT INTO "document_views" VALUES(917,21,NULL,'2026-10-23 14:58:40.563957');
INSERT INTO "document_views" VALUES(918,21,NULL,'2026-10-22 00:24:40.563957');
INSERT INTO "document_views" VALUES(919,22,NULL,'2026-10-17 04:09:40.563957');
INSERT INTO "document_views" VALUES(920,22,NULL,'2026-10-15 23:17:40.563957');
INSERT INTO "document_views" VALUES(921,22,NULL,'2026-10-20 05:56:40.563957');
INSERT INTO "document_views" VALUES(922,22,NULL,'2026-10-06 01:14:40.563957');
INSERT INTO "document_views" VALUES(923,22,NULL,'2026-10-24 01:12:40.563957');
INSERT INTO "document_views" VALUES(924,22,NULL,'2026-10-05 05:58:40.563957');
INSERT INTO "document_views" VALUES(925,22,NULL,'2026-10-01 17:39:40.563957');
INSERT INTO "document_views" VALUES(926,22,NULL,'2026-10-11 00:51:40.563957');
INSERT INTO "document_views" VALUES(927,22,NULL,'2026-10-03 21:20:40.563957');
INSERT INTO "document_views" VALUES(928,22,NULL,'2026-10-07 06:54:40.563957');
INSERT INTO "document_views" VALUES(929,22,NULL,'2026-10-26 10:38:40.563957');
INSERT INTO "document_views" VALUES(930,22,NULL,'2026-10-30 19:46:40.563957');
INSERT INTO "document_views" VALUES(931,22,NULL,'2026-10-26 09:19:40.563957');
INSERT INTO "document_views" VALUES(932,22,NULL,'2026-10-19 14:21:40.563957');
INSERT INTO "document_views" VALUES(933,22,NULL,'2026-10-07 02:38:40.563957');
INSERT INTO "document_views" VALUES(934,22,NULL,'2026-10-07 15:14:40.563957');
INSERT INTO "document_views" VALUES(935,22,NULL,'2026-10-28 03:22:40.563957');
INSERT INTO "document_views" VALUES(936,22,NULL,'2026-10-25 15:33:40.563957');
INSERT INTO "document_views" VALUES(937,22,NULL,'2026-10-17 00:51:40.563957');
INSERT INTO "document_views" VALUES(938,22,NULL,'2026-10-30 19:42:40.563957');
INSERT INTO "document_views" VALUES(939,22,NULL,'2026-10-10 11:50:40.563957');
INSERT INTO "document_views" VALUES(940,22,NULL,'2026-10-16 00:37:40.563957');
INSERT INTO "document_views" VALUES(941,24,NULL,'2026-10-16 17:22:40.563957');
INSERT INTO "document_views" VALUES(942,24,NULL,'2026-10-08 13:37:40.563957');
INSERT INTO "document_views" VALUES(943,24,NULL,'2026-10-25 17:32:40.563957');
INSERT INTO "document_views" VALUES(944,24,NULL,'2026-10-16 00:54:40.563957');
INSERT INTO "document_views" VALUES(945,24,NULL,'2026-10-01 14:55:40.563957');
INSERT INTO "document_views" VALUES(946,24,NULL,'2026-10-26 22:44:40.563957');
INSERT INTO "document_views" VALUES(947,24,NULL,'2026-10-30 18:07:40.563957');
INSERT INTO "document_views" VALUES(948,24,NULL,'2026-10-28 22:06:40.563957');
INSERT INTO "document_views" VALUES(949,24,NULL,'2026-10-03 20:54:40.563957');
INSERT INTO "document_views" VALUES(950,24,NULL,'2026-10-18 11:39:40.563957');
INSERT INTO "document_views" VALUES(951,24,NULL,'2026-10-30 08:54:40.563957');
INSERT INTO "document_views" VALUES(952,24,NULL,'2026-10-25 23:09:40.563957');
INSERT INTO "document_views" VALUES(953,24,NULL,'2026-10-31 03:10:40.563957');
INSERT INTO "document_views" VALUES(954,24,NULL,'2026-10-23 01:45:40.563957');
INSERT INTO "document_views" VALUES(955,24,NULL,'2026-10-23 14:03:40.563957');
INSERT INTO "document_views" VALUES(956,24,NULL,'2026-10-04 20:36:40.563957');
INSERT INTO "document_views" VALUES(957,24,NULL,'2026-10-14 09:24:40.563957');
INSERT INTO "document_views" VALUES(958,24,NULL,'2026-10-04 21:08:40.563957');
INSERT INTO "document_views" VALUES(959,24,NULL,'2026-10-24 23:40:40.563957');
INSERT INTO "document_views" VALUES(960,24,NULL,'2026-10-29 02:39:40.563957');
INSERT INTO "document_views" VALUES(961,24,NULL,'2026-10-21 15:41:40.563957');
INSERT INTO "document_views" VALUES(962,24,NULL,'2026-10-12 10:32:40.563957');
INSERT INTO "document_views" VALUES(963,24,NULL,'2026-10-24 07:15:40.563957');
INSERT INTO "document_views" VALUES(964,24,NULL,'2026-10-19 15:08:40.563957');
INSERT INTO "document_views" VALUES(965,24,NULL,'2026-10-11 08:32:40.563957');
INSERT INTO "document_views" VALUES(966,24,NULL,'2026-10-08 22:46:40.563957');
INSERT INTO "document_views" VALUES(967,24,NULL,'2026-10-14 10:52:40.563957');
INSERT INTO "document_views" VALUES(968,24,NULL,'2026-10-07 04:25:40.563957');
INSERT INTO "document_views" VALUES(969,24,NULL,'2026-10-20 13:11:40.563957');
INSERT INTO "document_views" VALUES(970,24,NULL,'2026-10-14 04:33:40.563957');
INSERT INTO "document_views" VALUES(971,24,NULL,'2026-10-05 03:23:40.563957');
INSERT INTO "document_views" VALUES(972,24,NULL,'2026-10-30 12:31:40.563957');
INSERT INTO "document_views" VALUES(973,24,NULL,'2026-10-06 00:18:40.563957');
INSERT INTO "document_views" VALUES(974,24,NULL,'2026-10-19 02:06:40.563957');
INSERT INTO "document_views" VALUES(975,24,NULL,'2026-10-29 13:27:40.563957');
INSERT INTO "document_views" VALUES(976,24,NULL,'2026-10-22 07:59:40.563957');
INSERT INTO "document_views" VALUES(977,24,NULL,'2026-10-28 11:18:40.563957');
INSERT INTO "document_views" VALUES(978,24,NULL,'2026-10-21 13:47:40.563957');
INSERT INTO "document_views" VALUES(979,24,NULL,'2026-10-23 05:19:40.563957');
INSERT INTO "document_views" VALUES(980,24,NULL,'2026-10-22 13:41:40.563957');
INSERT INTO "document_views" VALUES(981,24,NULL,'2026-10-23 11:58:40.563957');
INSERT INTO "document_views" VALUES(982,24,NULL,'2026-10-30 15:26:40.563957');
INSERT INTO "document_views" VALUES(983,24,NULL,'2026-10-15 20:41:40.563957');
INSERT INTO "document_views" VALUES(984,24,NULL,'2026-10-13 17:42:40.563957');
INSERT INTO "document_views" VALUES(985,24,NULL,'2026-10-28 07:06:40.563957');
INSERT INTO "document_views" VALUES(986,24,NULL,'2026-10-12 11:28:40.563957');
INSERT INTO "document_views" VALUES(987,24,NULL,'2026-10-30 16:45:40.563957');
INSERT INTO "document_views" VALUES(988,24,NULL,'2026-10-26 05:02:40.563957');
INSERT INTO "document_views" VALUES(989,24,NULL,'2026-10-20 05:09:40.563957');
INSERT INTO "document_views" VALUES(990,24,NULL,'2026-10-05 04:51:40.563957');
INSERT INTO "document_views" VALUES(991,24,NULL,'2026-10-01 15:06:40.563957');
INSERT INTO "document_views" VALUES(992,24,NULL,'2026-10-30 17:15:40.563957');
INSERT INTO "document_views" VALUES(993,24,NULL,'2026-10-30 02:35:40.563957');
INSERT INTO "document_views" VALUES(994,24,NULL,'2026-10-11 09:10:40.563957');
INSERT INTO "document_views" VALUES(995,24,NULL,'2026-10-02 18:26:40.563957');
INSERT INTO "document_views" VALUES(996,24,NULL,'2026-10-01 18:09:40.563957');
INSERT INTO "document_views" VALUES(997,24,NULL,'2026-10-22 18:19:40.563957');
INSERT INTO "document_views" VALUES(998,24,NULL,'2026-10-24 07:54:40.563957');
INSERT INTO "document_views" VALUES(999,24,NULL,'2026-10-02 12:48:40.563957');
INSERT INTO "document_views" VALUES(1000,24,NULL,'2026-10-29 19:20:40.563957');
INSERT INTO "document_views" VALUES(1001,25,NULL,'2026-10-19 13:09:40.563957');
INSERT INTO "document_views" VALUES(1002,25,NULL,'2026-10-29 23:36:40.563957');
INSERT INTO "document_views" VALUES(1003,25,NULL,'2026-10-09 06:26:40.563957');
INSERT INTO "document_views" VALUES(1004,25,NULL,'2026-10-02 15:24:40.563957');
INSERT INTO "document_views" VALUES(1005,25,NULL,'2026-10-15 12:37:40.563957');
INSERT INTO "document_views" VALUES(1006,25,NULL,'2026-10-23 18:16:40.563957');
INSERT INTO "document_views" VALUES(1007,25,NULL,'2026-10-09 22:46:40.563957');
INSERT INTO "document_views" VALUES(1008,25,NULL,'2026-10-23 01:55:40.563957');
INSERT INTO "document_views" VALUES(1009,25,NULL,'2026-10-28 03:21:40.563957');
INSERT INTO "document_views" VALUES(1010,25,NULL,'2026-10-30 08:40:40.563957');
INSERT INTO "document_views" VALUES(1011,25,NULL,'2026-10-24 06:40:40.563957');
INSERT INTO "document_views" VALUES(1012,25,NULL,'2026-10-28 04:55:40.563957');
INSERT INTO "document_views" VALUES(1013,26,NULL,'2026-10-22 08:16:40.563957');
INSERT INTO "document_views" VALUES(1014,26,NULL,'2026-10-14 05:33:40.563957');
INSERT INTO "document_views" VALUES(1015,26,NULL,'2026-10-28 05:42:40.563957');
INSERT INTO "document_views" VALUES(1016,26,NULL,'2026-10-24 23:13:40.563957');
INSERT INTO "document_views" VALUES(1017,26,NULL,'2026-10-20 05:17:40.563957');
INSERT INTO "document_views" VALUES(1018,26,NULL,'2026-10-29 21:20:40.563957');
INSERT INTO "document_views" VALUES(1019,26,NULL,'2026-10-28 11:33:40.563957');
INSERT INTO "document_views" VALUES(1020,26,NULL,'2026-10-26 10:48:40.563957');
INSERT INTO "document_views" VALUES(1021,26,NULL,'2026-10-11 20:16:40.563957');
INSERT INTO "document_views" VALUES(1022,26,NULL,'2026-10-29 02:19:40.563957');
INSERT INTO "document_views" VALUES(1023,26,NULL,'2026-10-01 13:25:40.563957');
INSERT INTO "document_views" VALUES(1024,26,NULL,'2026-10-28 20:57:40.563957');
INSERT INTO "document_views" VALUES(1025,26,NULL,'2026-10-27 12:12:40.563957');
INSERT INTO "document_views" VALUES(1026,26,NULL,'2026-10-04 01:14:40.563957');
INSERT INTO "document_views" VALUES(1027,26,NULL,'2026-10-16 16:38:40.563957');
INSERT INTO "document_views" VALUES(1028,26,NULL,'2026-10-20 05:36:40.563957');
INSERT INTO "document_views" VALUES(1029,26,NULL,'2026-10-02 09:15:40.563957');
INSERT INTO "document_views" VALUES(1030,26,NULL,'2026-10-15 13:18:40.563957');
INSERT INTO "document_views" VALUES(1031,26,NULL,'2026-10-26 17:00:40.563957');
INSERT INTO "document_views" VALUES(1032,26,NULL,'2026-10-23 20:58:40.563957');
INSERT INTO "document_views" VALUES(1033,26,NULL,'2026-10-24 12:51:40.563957');
INSERT INTO "document_views" VALUES(1034,26,NULL,'2026-10-21 23:31:40.563957');
INSERT INTO "document_views" VALUES(1035,26,NULL,'2026-10-27 02:17:40.563957');
INSERT INTO "document_views" VALUES(1036,26,NULL,'2026-10-10 05:14:40.563957');
INSERT INTO "document_views" VALUES(1037,26,NULL,'2026-10-19 16:59:40.563957');
INSERT INTO "document_views" VALUES(1038,26,NULL,'2026-10-20 02:38:40.563957');
INSERT INTO "document_views" VALUES(1039,26,NULL,'2026-10-24 22:30:40.563957');
INSERT INTO "document_views" VALUES(1040,26,NULL,'2026-10-28 09:08:40.563957');
INSERT INTO "document_views" VALUES(1041,26,NULL,'2026-10-30 15:51:40.563957');
INSERT INTO "document_views" VALUES(1042,26,NULL,'2026-10-08 04:03:40.563957');
INSERT INTO "document_views" VALUES(1043,26,NULL,'2026-10-20 00:42:40.563957');
INSERT INTO "document_views" VALUES(1044,26,NULL,'2026-10-30 18:20:40.563957');
INSERT INTO "document_views" VALUES(1045,26,NULL,'2026-10-15 10:38:40.563957');
INSERT INTO "document_views" VALUES(1046,26,NULL,'2026-10-31 04:43:40.563957');
INSERT INTO "document_views" VALUES(1047,26,NULL,'2026-10-28 11:09:40.563957');
INSERT INTO "document_views" VALUES(1048,26,NULL,'2026-10-13 12:08:40.563957');
INSERT INTO "document_views" VALUES(1049,26,NULL,'2026-10-29 00:05:40.563957');
INSERT INTO "document_views" VALUES(1050,26,NULL,'2026-10-07 19:51:40.563957');
INSERT INTO "document_views" VALUES(1051,26,NULL,'2026-10-27 06:41:40.563957');
INSERT INTO "document_views" VALUES(1052,26,NULL,'2026-10-29 00:43:40.563957');
INSERT INTO "document_views" VALUES(1053,26,NULL,'2026-10-03 03:12:40.563957');
INSERT INTO "document_views" VALUES(1054,26,NULL,'2026-10-12 14:52:40.563957');
INSERT INTO "document_views" VALUES(1055,26,NULL,'2026-10-05 07:28:40.563957');
INSERT INTO "document_views" VALUES(1056,26,NULL,'2026-10-18 00:14:40.563957');
INSERT INTO "document_views" VALUES(1057,26,NULL,'2026-10-24 23:02:40.563957');
INSERT INTO "document_views" VALUES(1058,26,NULL,'2026-10-19 21:33:40.563957');
INSERT INTO "document_views" VALUES(1059,26,NULL,'2026-10-24 13:00:40.563957');
INSERT INTO "document_views" VALUES(1060,26,NULL,'2026-10-15 20:41:40.563957');
INSERT INTO "document_views" VALUES(1061,26,NULL,'2026-10-27 13:42:40.563957');
INSERT INTO "document_views" VALUES(1062,26,NULL,'2026-10-06 15:18:40.563957');
INSERT INTO "document_views" VALUES(1063,26,NULL,'2026-10-30 15:11:40.563957');
INSERT INTO "document_views" VALUES(1064,26,NULL,'2026-10-11 20:17:40.563957');
INSERT INTO "document_views" VALUES(1065,26,NULL,'2026-10-05 18:33:40.563957');
INSERT INTO "document_views" VALUES(1066,26,NULL,'2026-10-27 05:39:40.563957');
INSERT INTO "document_views" VALUES(1067,26,NULL,'2026-10-19 23:39:40.563957');
INSERT INTO "document_views" VALUES(1068,26,NULL,'2026-10-13 06:39:40.563957');
INSERT INTO "document_views" VALUES(1069,26,NULL,'2026-10-27 11:16:40.563957');
INSERT INTO "document_views" VALUES(1070,27,NULL,'2026-10-27 00:31:40.563957');
INSERT INTO "document_views" VALUES(1071,27,NULL,'2026-10-25 18:15:40.563957');
INSERT INTO "document_views" VALUES(1072,27,NULL,'2026-10-18 22:49:40.563957');
INSERT INTO "document_views" VALUES(1073,27,NULL,'2026-10-21 08:52:40.563957');
INSERT INTO "document_views" VALUES(1074,27,NULL,'2026-10-03 19:41:40.563957');
INSERT INTO "document_views" VALUES(1075,27,NULL,'2026-10-27 14:32:40.563957');
INSERT INTO "document_views" VALUES(1076,27,NULL,'2026-10-02 09:18:40.563957');
INSERT INTO "document_views" VALUES(1077,27,NULL,'2026-10-12 15:29:40.563957');
INSERT INTO "document_views" VALUES(1078,27,NULL,'2026-10-29 19:11:40.563957');
INSERT INTO "document_views" VALUES(1079,27,NULL,'2026-10-29 12:33:40.563957');
INSERT INTO "document_views" VALUES(1080,27,NULL,'2026-10-21 12:42:40.563957');
INSERT INTO "document_views" VALUES(1081,27,NULL,'2026-10-02 05:12:40.563957');
INSERT INTO "document_views" VALUES(1082,27,NULL,'2026-10-21 04:40:40.563957');
INSERT INTO "document_views" VALUES(1083,27,NULL,'2026-10-03 08:24:40.563957');
INSERT INTO "document_views" VALUES(1084,27,NULL,'2026-10-31 06:59:40.563957');
INSERT INTO "document_views" VALUES(1085,27,NULL,'2026-10-23 09:41:40.563957');
INSERT INTO "document_views" VALUES(1086,27,NULL,'2026-10-29 02:03:40.563957');
INSERT INTO "document_views" VALUES(1087,27,NULL,'2026-10-30 13:57:40.563957');
INSERT INTO "document_views" VALUES(1088,27,NULL,'2026-10-23 05:09:40.563957');
INSERT INTO "document_views" VALUES(1089,27,NULL,'2026-10-17 08:27:40.563957');
INSERT INTO "document_views" VALUES(1090,27,NULL,'2026-10-04 14:43:40.563957');
INSERT INTO "document_views" VALUES(1091,27,NULL,'2026-10-16 06:40:40.563957');
INSERT INTO "document_views" VALUES(1092,27,NULL,'2026-10-30 12:23:40.563957');
INSERT INTO "document_views" VALUES(1093,27,NULL,'2026-10-24 06:38:40.563957');
INSERT INTO "document_views" VALUES(1094,27,NULL,'2026-10-20 21:50:40.563957');
INSERT INTO "document_views" VALUES(1095,27,NULL,'2026-10-19 21:25:40.563957');
INSERT INTO "document_views" VALUES(1096,27,NULL,'2026-10-30 07:23:40.563957');
INSERT INTO "document_views" VALUES(1097,27,NULL,'2026-10-16 01:05:40.563957');
INSERT INTO "document_views" VALUES(1098,27,NULL,'2026-10-31 03:55:40.563957');
INSERT INTO "document_views" VALUES(1099,27,NULL,'2026-10-20 22:59:40.563957');
INSERT INTO "document_views" VALUES(1100,27,NULL,'2026-10-28 13:14:40.563957');
INSERT INTO "document_views" VALUES(1101,27,NULL,'2026-10-27 19:07:40.563957');
INSERT INTO "document_views" VALUES(1102,27,NULL,'2026-10-27 17:40:40.563957');
INSERT INTO "document_views" VALUES(1103,27,NULL,'2026-10-30 17:21:40.563957');
INSERT INTO "document_views" VALUES(1104,27,NULL,'2026-10-22 22:54:40.563957');
INSERT INTO "document_views" VALUES(1105,27,NULL,'2026-10-01 23:30:40.563957');
INSERT INTO "document_views" VALUES(1106,27,NULL,'2026-10-27 04:27:40.563957');
INSERT INTO "document_views" VALUES(1107,27,NULL,'2026-10-15 09:02:40.563957');
INSERT INTO "document_views" VALUES(1108,27,NULL,'2026-10-12 04:01:40.563957');
INSERT INTO "document_views" VALUES(1109,27,NULL,'2026-10-23 18:20:40.563957');
INSERT INTO "document_views" VALUES(1110,27,NULL,'2026-10-20 05:18:40.563957');
INSERT INTO "document_views" VALUES(1111,27,NULL,'2026-10-16 07:13:40.563957');
INSERT INTO "document_views" VALUES(1112,27,NULL,'2026-10-29 14:09:40.563957');
INSERT INTO "document_views" VALUES(1113,27,NULL,'2026-10-08 09:12:40.563957');
INSERT INTO "document_views" VALUES(1114,27,NULL,'2026-10-10 11:54:40.563957');
INSERT INTO "document_views" VALUES(1115,27,NULL,'2026-10-03 03:57:40.563957');
INSERT INTO "document_views" VALUES(1116,27,NULL,'2026-10-06 05:45:40.563957');
INSERT INTO "document_views" VALUES(1117,27,NULL,'2026-10-28 07:35:40.563957');
INSERT INTO "document_views" VALUES(1118,27,NULL,'2026-10-06 14:59:40.563957');
INSERT INTO "document_views" VALUES(1119,27,NULL,'2026-10-28 04:40:40.563957');
INSERT INTO "document_views" VALUES(1120,27,NULL,'2026-10-14 21:38:40.563957');
INSERT INTO "document_views" VALUES(1121,27,NULL,'2026-10-05 11:58:40.563957');
INSERT INTO "document_views" VALUES(1122,27,NULL,'2026-10-16 01:05:40.563957');
INSERT INTO "document_views" VALUES(1123,27,NULL,'2026-10-04 20:28:40.563957');
INSERT INTO "document_views" VALUES(1124,27,NULL,'2026-10-31 00:08:40.563957');
INSERT INTO "document_views" VALUES(1125,27,NULL,'2026-10-18 17:37:40.563957');
INSERT INTO "document_views" VALUES(1126,27,NULL,'2026-10-04 21:00:40.563957');
INSERT INTO "document_views" VALUES(1127,27,NULL,'2026-10-29 23:00:40.563957');
INSERT INTO "document_views" VALUES(1128,27,NULL,'2026-10-18 17:56:40.563957');
INSERT INTO "document_views" VALUES(1129,27,NULL,'2026-10-14 12:45:40.563957');
INSERT INTO "document_views" VALUES(1130,27,NULL,'2026-10-26 02:26:40.563957');
INSERT INTO "document_views" VALUES(1131,27,NULL,'2026-10-10 07:41:40.563957');
INSERT INTO "document_views" VALUES(1132,27,NULL,'2026-10-13 14:07:40.563957');
INSERT INTO "document_views" VALUES(1133,27,NULL,'2026-10-12 19:24:40.563957');
INSERT INTO "document_views" VALUES(1134,27,NULL,'2026-10-30 16:17:40.563957');
INSERT INTO "document_views" VALUES(1135,27,NULL,'2026-10-29 04:37:40.563957');
INSERT INTO "document_views" VALUES(1136,27,NULL,'2026-10-25 10:15:40.563957');
INSERT INTO "document_views" VALUES(1137,27,NULL,'2026-10-03 17:40:40.563957');
INSERT INTO "document_views" VALUES(1138,27,NULL,'2026-10-02 20:04:40.563957');
INSERT INTO "document_views" VALUES(1139,27,NULL,'2026-10-30 21:53:40.563957');
INSERT INTO "document_views" VALUES(1140,27,NULL,'2026-10-10 15:50:40.563957');
INSERT INTO "document_views" VALUES(1141,27,NULL,'2026-10-21 19:04:40.563957');
INSERT INTO "document_views" VALUES(1142,27,NULL,'2026-10-19 18:24:40.563957');
INSERT INTO "document_views" VALUES(1143,27,NULL,'2026-10-23 08:00:40.563957');
INSERT INTO "document_views" VALUES(1144,27,NULL,'2026-10-18 18:14:40.563957');
INSERT INTO "document_views" VALUES(1145,27,NULL,'2026-10-30 10:06:40.563957');
INSERT INTO "document_views" VALUES(1146,27,NULL,'2026-10-26 22:48:40.563957');
INSERT INTO "document_views" VALUES(1147,27,NULL,'2026-10-14 04:24:40.563957');
INSERT INTO "document_views" VALUES(1148,27,NULL,'2026-10-27 18:14:40.563957');
INSERT INTO "document_views" VALUES(1149,27,NULL,'2026-10-13 09:34:40.563957');
INSERT INTO "document_views" VALUES(1150,28,NULL,'2026-10-27 03:34:40.563957');
INSERT INTO "document_views" VALUES(1151,28,NULL,'2026-10-30 20:41:40.563957');
INSERT INTO "document_views" VALUES(1152,28,NULL,'2026-10-22 22:00:40.563957');
INSERT INTO "document_views" VALUES(1153,28,NULL,'2026-10-31 04:14:40.563957');
INSERT INTO "document_views" VALUES(1154,28,NULL,'2026-10-28 15:53:40.563957');
INSERT INTO "document_views" VALUES(1155,28,NULL,'2026-10-19 13:43:40.563957');
INSERT INTO "document_views" VALUES(1156,28,NULL,'2026-10-24 06:19:40.563957');
INSERT INTO "document_views" VALUES(1157,28,NULL,'2026-10-30 12:17:40.563957');
INSERT INTO "document_views" VALUES(1158,28,NULL,'2026-10-30 10:48:40.563957');
INSERT INTO "document_views" VALUES(1159,28,NULL,'2026-10-10 18:04:40.563957');
INSERT INTO "document_views" VALUES(1160,28,NULL,'2026-10-30 17:05:40.563957');
INSERT INTO "document_views" VALUES(1161,28,NULL,'2026-10-25 04:19:40.563957');
INSERT INTO "document_views" VALUES(1162,28,NULL,'2026-10-13 12:07:40.563957');
INSERT INTO "document_views" VALUES(1163,28,NULL,'2026-10-05 22:55:40.563957');
INSERT INTO "document_views" VALUES(1164,28,NULL,'2026-10-19 01:25:40.563957');
INSERT INTO "document_views" VALUES(1165,28,NULL,'2026-10-15 01:25:40.563957');
INSERT INTO "document_views" VALUES(1166,28,NULL,'2026-10-29 20:56:40.563957');
INSERT INTO "document_views" VALUES(1167,28,NULL,'2026-10-28 02:14:40.563957');
INSERT INTO "document_views" VALUES(1168,28,NULL,'2026-10-30 16:22:40.563957');
INSERT INTO "document_views" VALUES(1169,28,NULL,'2026-10-27 20:59:40.563957');
INSERT INTO "document_views" VALUES(1170,28,NULL,'2026-10-22 04:35:40.563957');
INSERT INTO "document_views" VALUES(1171,28,NULL,'2026-10-25 22:47:40.563957');
INSERT INTO "document_views" VALUES(1172,28,NULL,'2026-10-13 14:17:40.563957');
INSERT INTO "document_views" VALUES(1173,28,NULL,'2026-10-18 00:32:40.563957');
INSERT INTO "document_views" VALUES(1174,28,NULL,'2026-10-23 02:35:40.563957');
INSERT INTO "document_views" VALUES(1175,28,NULL,'2026-10-26 17:42:40.563957');
INSERT INTO "document_views" VALUES(1176,28,NULL,'2026-10-25 10:02:40.563957');
INSERT INTO "document_views" VALUES(1177,28,NULL,'2026-10-24 19:58:40.563957');
INSERT INTO "document_views" VALUES(1178,28,NULL,'2026-10-22 16:31:40.563957');
INSERT INTO "document_views" VALUES(1179,28,NULL,'2026-10-09 08:59:40.563957');
INSERT INTO "document_views" VALUES(1180,28,NULL,'2026-10-03 02:34:40.563957');
INSERT INTO "document_views" VALUES(1181,28,NULL,'2026-10-26 10:37:40.563957');
INSERT INTO "document_views" VALUES(1182,28,NULL,'2026-10-04 00:21:40.563957');
INSERT INTO "document_views" VALUES(1183,28,NULL,'2026-10-22 01:09:40.563957');
INSERT INTO "document_views" VALUES(1184,28,NULL,'2026-10-02 20:19:40.563957');
INSERT INTO "document_views" VALUES(1185,28,NULL,'2026-10-26 07:29:40.563957');
INSERT INTO "document_views" VALUES(1186,28,NULL,'2026-10-16 11:33:40.563957');
INSERT INTO "document_views" VALUES(1187,28,NULL,'2026-10-10 20:05:40.563957');
INSERT INTO "document_views" VALUES(1188,28,NULL,'2026-10-24 17:48:40.563957');
INSERT INTO "document_views" VALUES(1189,28,NULL,'2026-10-25 11:58:40.563957');
INSERT INTO "document_views" VALUES(1190,28,NULL,'2026-10-28 12:35:40.563957');
INSERT INTO "document_views" VALUES(1191,28,NULL,'2026-10-29 12:26:40.563957');
INSERT INTO "document_views" VALUES(1192,28,NULL,'2026-10-30 15:27:40.563957');
INSERT INTO "document_views" VALUES(1193,28,NULL,'2026-10-04 00:03:40.563957');
INSERT INTO "document_views" VALUES(1194,28,NULL,'2026-10-22 21:16:40.563957');
INSERT INTO "document_views" VALUES(1195,28,NULL,'2026-10-09 04:51:40.563957');
INSERT INTO "document_views" VALUES(1196,28,NULL,'2026-10-09 17:15:40.563957');
INSERT INTO "document_views" VALUES(1197,28,NULL,'2026-10-16 02:27:40.563957');
INSERT INTO "document_views" VALUES(1198,28,NULL,'2026-10-16 22:57:40.563957');
INSERT INTO "document_views" VALUES(1199,28,NULL,'2026-10-28 01:57:40.563957');
INSERT INTO "document_views" VALUES(1200,28,NULL,'2026-10-13 18:20:40.563957');
INSERT INTO "document_views" VALUES(1201,28,NULL,'2026-10-30 10:48:40.563957');
INSERT INTO "document_views" VALUES(1202,28,NULL,'2026-10-21 17:32:40.563957');
INSERT INTO "document_views" VALUES(1203,28,NULL,'2026-10-19 07:36:40.563957');
INSERT INTO "document_views" VALUES(1204,28,NULL,'2026-10-24 05:57:40.563957');
INSERT INTO "document_views" VALUES(1205,28,NULL,'2026-10-10 18:56:40.563957');
INSERT INTO "document_views" VALUES(1206,28,NULL,'2026-10-13 12:53:40.563957');
INSERT INTO "document_views" VALUES(1207,28,NULL,'2026-10-18 04:18:40.563957');
INSERT INTO "document_views" VALUES(1208,28,NULL,'2026-10-30 22:44:40.563957');
INSERT INTO "document_views" VALUES(1209,28,NULL,'2026-10-15 19:05:40.563957');
INSERT INTO "document_views" VALUES(1210,28,NULL,'2026-10-29 10:18:40.563957');
INSERT INTO "document_views" VALUES(1211,28,NULL,'2026-10-30 09:11:40.563957');
INSERT INTO "document_views" VALUES(1212,28,NULL,'2026-10-14 17:34:40.563957');
INSERT INTO "document_views" VALUES(1213,28,NULL,'2026-10-02 19:53:40.563957');
INSERT INTO "document_views" VALUES(1214,28,NULL,'2026-10-02 16:31:40.563957');
INSERT INTO "document_views" VALUES(1215,28,NULL,'2026-10-31 03:51:40.563957');
INSERT INTO "document_views" VALUES(1216,28,NULL,'2026-10-27 13:47:40.563957');
INSERT INTO "document_views" VALUES(1217,28,NULL,'2026-10-12 12:10:40.563957');
INSERT INTO "document_views" VALUES(1218,28,NULL,'2026-10-18 11:34:40.563957');
INSERT INTO "document_views" VALUES(1219,28,NULL,'2026-10-28 18:26:40.563957');
INSERT INTO "document_views" VALUES(1220,28,NULL,'2026-10-24 08:01:40.563957');
INSERT INTO "document_views" VALUES(1221,28,NULL,'2026-10-18 14:08:40.563957');
INSERT INTO "document_views" VALUES(1222,28,NULL,'2026-10-30 06:22:40.563957');
INSERT INTO "document_views" VALUES(1223,28,NULL,'2026-10-21 21:07:40.563957');
INSERT INTO "document_views" VALUES(1224,28,NULL,'2026-10-24 04:17:40.563957');
INSERT INTO "document_views" VALUES(1225,28,NULL,'2026-10-31 02:22:40.563957');
INSERT INTO "document_views" VALUES(1226,28,NULL,'2026-10-25 19:30:40.563957');
INSERT INTO "document_views" VALUES(1227,28,NULL,'2026-10-23 00:09:40.563957');
INSERT INTO "document_views" VALUES(1228,28,NULL,'2026-10-20 19:19:40.563957');
INSERT INTO "document_views" VALUES(1229,28,NULL,'2026-10-21 16:15:40.563957');
INSERT INTO "document_views" VALUES(1230,28,NULL,'2026-10-13 15:46:40.563957');
INSERT INTO "document_views" VALUES(1231,28,NULL,'2026-10-26 20:58:40.563957');
INSERT INTO "document_views" VALUES(1232,28,NULL,'2026-10-31 03:17:40.563957');
INSERT INTO "document_views" VALUES(1233,28,NULL,'2026-10-30 19:30:40.563957');
INSERT INTO "document_views" VALUES(1234,29,NULL,'2026-10-10 22:53:40.563957');
INSERT INTO "document_views" VALUES(1235,29,NULL,'2026-10-20 12:22:40.563957');
INSERT INTO "document_views" VALUES(1236,29,NULL,'2026-10-29 12:06:40.563957');
INSERT INTO "document_views" VALUES(1237,29,NULL,'2026-10-23 15:26:40.563957');
INSERT INTO "document_views" VALUES(1238,29,NULL,'2026-10-28 17:23:40.563957');
INSERT INTO "document_views" VALUES(1239,29,NULL,'2026-10-17 00:51:40.563957');
INSERT INTO "document_views" VALUES(1240,29,NULL,'2026-10-16 16:27:40.563957');
INSERT INTO "document_views" VALUES(1241,29,NULL,'2026-10-24 10:15:40.563957');
INSERT INTO "document_views" VALUES(1242,29,NULL,'2026-10-06 15:52:40.563957');
INSERT INTO "document_views" VALUES(1243,30,NULL,'2026-10-30 23:53:40.563957');
INSERT INTO "document_views" VALUES(1244,30,NULL,'2026-10-29 05:04:40.563957');
INSERT INTO "document_views" VALUES(1245,30,NULL,'2026-10-18 12:53:40.563957');
INSERT INTO "document_views" VALUES(1246,30,NULL,'2026-10-28 20:05:40.563957');
INSERT INTO "document_views" VALUES(1247,30,NULL,'2026-10-29 03:19:40.563957');
INSERT INTO "document_views" VALUES(1248,30,NULL,'2026-10-27 14:30:40.563957');
INSERT INTO "document_views" VALUES(1249,30,NULL,'2026-10-20 09:24:40.563957');
INSERT INTO "document_views" VALUES(1250,30,NULL,'2026-10-26 17:57:40.563957');
INSERT INTO "document_views" VALUES(1251,30,NULL,'2026-10-17 11:10:40.563957');
INSERT INTO "document_views" VALUES(1252,30,NULL,'2026-10-30 19:12:40.563957');
INSERT INTO "document_views" VALUES(1253,30,NULL,'2026-10-08 10:08:40.563957');
INSERT INTO "document_views" VALUES(1254,30,NULL,'2026-10-29 08:13:40.563957');
INSERT INTO "document_views" VALUES(1255,30,NULL,'2026-10-13 21:03:40.563957');
INSERT INTO "document_views" VALUES(1256,30,NULL,'2026-10-04 11:04:40.563957');
INSERT INTO "document_views" VALUES(1257,30,NULL,'2026-10-31 02:38:40.563957');
INSERT INTO "document_views" VALUES(1258,30,NULL,'2026-10-26 23:04:40.563957');
INSERT INTO "document_views" VALUES(1259,30,NULL,'2026-10-27 00:58:40.563957');
INSERT INTO "document_views" VALUES(1260,30,NULL,'2026-10-25 02:23:40.563957');
INSERT INTO "document_views" VALUES(1261,30,NULL,'2026-10-20 16:56:40.563957');
INSERT INTO "document_views" VALUES(1262,30,NULL,'2026-10-17 11:35:40.563957');
INSERT INTO "document_views" VALUES(1263,30,NULL,'2026-10-25 00:52:40.563957');
INSERT INTO "document_views" VALUES(1264,30,NULL,'2026-10-21 12:52:40.563957');
INSERT INTO "document_views" VALUES(1265,30,NULL,'2026-10-14 09:11:40.563957');
INSERT INTO "document_views" VALUES(1266,30,NULL,'2026-10-05 01:18:40.563957');
INSERT INTO "document_views" VALUES(1267,30,NULL,'2026-10-19 14:30:40.563957');
INSERT INTO "document_views" VALUES(1268,30,NULL,'2026-10-27 00:49:40.563957');
INSERT INTO "document_views" VALUES(1269,30,NULL,'2026-10-26 15:49:40.563957');
INSERT INTO "document_views" VALUES(1270,30,NULL,'2026-10-17 18:57:40.563957');
INSERT INTO "document_views" VALUES(1271,30,NULL,'2026-10-03 14:40:40.563957');
INSERT INTO "document_views" VALUES(1272,30,NULL,'2026-10-29 18:06:40.563957');
INSERT INTO "document_views" VALUES(1273,30,NULL,'2026-10-02 13:57:40.563957');
INSERT INTO "document_views" VALUES(1274,30,NULL,'2026-10-15 17:15:40.563957');
INSERT INTO "document_views" VALUES(1275,30,NULL,'2026-10-14 17:01:40.563957');
INSERT INTO "document_views" VALUES(1276,31,NULL,'2026-10-31 06:09:40.563957');
INSERT INTO "document_views" VALUES(1277,31,NULL,'2026-10-10 23:41:40.563957');
INSERT INTO "document_views" VALUES(1278,31,NULL,'2026-10-26 21:50:40.563957');
INSERT INTO "document_views" VALUES(1279,31,NULL,'2026-10-28 21:21:40.563957');
INSERT INTO "document_views" VALUES(1280,31,NULL,'2026-10-29 15:36:40.563957');
INSERT INTO "document_views" VALUES(1281,31,NULL,'2026-10-18 14:18:40.563957');
INSERT INTO "document_views" VALUES(1282,31,NULL,'2026-10-20 03:21:40.563957');
INSERT INTO "document_views" VALUES(1283,31,NULL,'2026-10-18 22:04:40.563957');
INSERT INTO "document_views" VALUES(1284,31,NULL,'2026-10-11 18:41:40.563957');
INSERT INTO "document_views" VALUES(1285,31,NULL,'2026-10-20 05:47:40.563957');
INSERT INTO "document_views" VALUES(1286,31,NULL,'2026-10-11 16:09:40.563957');
INSERT INTO "document_views" VALUES(1287,31,NULL,'2026-10-19 16:42:40.563957');
INSERT INTO "document_views" VALUES(1288,31,NULL,'2026-10-30 08:54:40.563957');
INSERT INTO "document_views" VALUES(1289,31,NULL,'2026-10-12 21:03:40.563957');
INSERT INTO "document_views" VALUES(1290,31,NULL,'2026-10-07 06:06:40.563957');
INSERT INTO "document_views" VALUES(1291,31,NULL,'2026-10-22 19:19:40.563957');
INSERT INTO "document_views" VALUES(1292,31,NULL,'2026-10-08 04:14:40.563957');
INSERT INTO "document_views" VALUES(1293,31,NULL,'2026-10-23 03:12:40.563957');
INSERT INTO "document_views" VALUES(1294,31,NULL,'2026-10-11 23:07:40.563957');
INSERT INTO "document_views" VALUES(1295,31,NULL,'2026-10-28 11:08:40.563957');
INSERT INTO "document_views" VALUES(1296,31,NULL,'2026-10-14 10:23:40.563957');
INSERT INTO "document_views" VALUES(1297,31,NULL,'2026-10-17 01:33:40.563957');
INSERT INTO "document_views" VALUES(1298,31,NULL,'2026-10-18 00:09:40.563957');
INSERT INTO "document_views" VALUES(1299,31,NULL,'2026-10-10 05:11:40.563957');
INSERT INTO "document_views" VALUES(1300,31,NULL,'2026-10-18 13:02:40.563957');
INSERT INTO "document_views" VALUES(1301,31,NULL,'2026-10-27 12:49:40.563957');
INSERT INTO "document_views" VALUES(1302,31,NULL,'2026-10-29 21:13:40.563957');
INSERT INTO "document_views" VALUES(1303,31,NULL,'2026-10-26 22:05:40.563957');
INSERT INTO "document_views" VALUES(1304,31,NULL,'2026-10-03 13:39:40.563957');
INSERT INTO "document_views" VALUES(1305,31,NULL,'2026-10-01 08:01:40.563957');
INSERT INTO "document_views" VALUES(1306,31,NULL,'2026-10-10 02:35:40.563957');
INSERT INTO "document_views" VALUES(1307,31,NULL,'2026-10-02 17:10:40.563957');
INSERT INTO "document_views" VALUES(1308,31,NULL,'2026-10-04 21:45:40.563957');
INSERT INTO "document_views" VALUES(1309,31,NULL,'2026-10-08 02:53:40.563957');
INSERT INTO "document_views" VALUES(1310,31,NULL,'2026-10-14 02:41:40.563957');
INSERT INTO "document_views" VALUES(1311,31,NULL,'2026-10-27 20:13:40.563957');
INSERT INTO "document_views" VALUES(1312,31,NULL,'2026-10-08 08:08:40.563957');
INSERT INTO "document_views" VALUES(1313,31,NULL,'2026-10-25 02:21:40.563957');
INSERT INTO "document_views" VALUES(1314,31,NULL,'2026-10-18 22:02:40.563957');
INSERT INTO "document_views" VALUES(1315,31,NULL,'2026-10-16 18:24:40.563957');
INSERT INTO "document_views" VALUES(1316,31,NULL,'2026-10-22 09:35:40.563957');
INSERT INTO "document_views" VALUES(1317,32,NULL,'2026-10-12 07:30:40.563957');
INSERT INTO "document_views" VALUES(1318,32,NULL,'2026-10-03 18:37:40.563957');
INSERT INTO "document_views" VALUES(1319,32,NULL,'2026-10-22 14:33:40.563957');
INSERT INTO "document_views" VALUES(1320,32,NULL,'2026-10-26 07:07:40.563957');
INSERT INTO "document_views" VALUES(1321,32,NULL,'2026-10-08 04:02:40.563957');
INSERT INTO "document_views" VALUES(1322,32,NULL,'2026-10-12 15:34:40.563957');
INSERT INTO "document_views" VALUES(1323,32,NULL,'2026-10-16 07:24:40.563957');
INSERT INTO "document_views" VALUES(1324,32,NULL,'2026-10-26 05:03:40.563957');
INSERT INTO "document_views" VALUES(1325,32,NULL,'2026-10-10 17:38:40.563957');
INSERT INTO "document_views" VALUES(1326,32,NULL,'2026-10-28 16:33:40.563957');
INSERT INTO "document_views" VALUES(1327,32,NULL,'2026-10-08 14:19:40.563957');
INSERT INTO "document_views" VALUES(1328,32,NULL,'2026-10-27 21:32:40.563957');
INSERT INTO "document_views" VALUES(1329,32,NULL,'2026-10-25 11:29:40.563957');
INSERT INTO "document_views" VALUES(1330,32,NULL,'2026-10-29 14:39:40.563957');
INSERT INTO "document_views" VALUES(1331,32,NULL,'2026-10-10 07:55:40.563957');
INSERT INTO "document_views" VALUES(1332,32,NULL,'2026-10-12 05:38:40.563957');
INSERT INTO "document_views" VALUES(1333,32,NULL,'2026-10-30 15:31:40.563957');
INSERT INTO "document_views" VALUES(1334,32,NULL,'2026-10-31 01:49:40.563957');
INSERT INTO "document_views" VALUES(1335,32,NULL,'2026-10-23 07:11:40.563957');
INSERT INTO "document_views" VALUES(1336,32,NULL,'2026-10-01 16:36:40.563957');
INSERT INTO "document_views" VALUES(1337,32,NULL,'2026-10-28 07:42:40.563957');
INSERT INTO "document_views" VALUES(1338,32,NULL,'2026-10-05 09:01:40.563957');
INSERT INTO "document_views" VALUES(1339,32,NULL,'2026-10-26 21:51:40.563957');
INSERT INTO "document_views" VALUES(1340,32,NULL,'2026-10-30 18:54:40.563957');
INSERT INTO "document_views" VALUES(1341,32,NULL,'2026-10-27 18:31:40.563957');
INSERT INTO "document_views" VALUES(1342,32,NULL,'2026-10-15 09:04:40.563957');
INSERT INTO "document_views" VALUES(1343,32,NULL,'2026-10-29 17:41:40.563957');
INSERT INTO "document_views" VALUES(1344,32,NULL,'2026-10-16 07:20:40.563957');
INSERT INTO "document_views" VALUES(1345,32,NULL,'2026-10-11 16:33:40.563957');
INSERT INTO "document_views" VALUES(1346,32,NULL,'2026-10-16 03:58:40.563957');
INSERT INTO "document_views" VALUES(1347,33,NULL,'2026-10-30 10:57:40.563957');
INSERT INTO "document_views" VALUES(1348,33,NULL,'2026-10-28 08:00:40.563957');
INSERT INTO "document_views" VALUES(1349,33,NULL,'2026-10-23 06:56:40.563957');
INSERT INTO "document_views" VALUES(1350,33,NULL,'2026-10-15 03:06:40.563957');
INSERT INTO "document_views" VALUES(1351,33,NULL,'2026-10-01 16:48:40.563957');
INSERT INTO "document_views" VALUES(1352,33,NULL,'2026-10-14 14:54:40.563957');
INSERT INTO "document_views" VALUES(1353,33,NULL,'2026-10-30 18:08:40.563957');
INSERT INTO "document_views" VALUES(1354,33,NULL,'2026-10-31 03:43:40.563957');
INSERT INTO "document_views" VALUES(1355,33,NULL,'2026-10-30 18:40:40.563957');
INSERT INTO "document_views" VALUES(1356,33,NULL,'2026-10-07 02:32:40.563957');
INSERT INTO "document_views" VALUES(1357,33,NULL,'2026-10-25 02:40:40.563957');
INSERT INTO "document_views" VALUES(1358,33,NULL,'2026-10-16 08:06:40.563957');
INSERT INTO "document_views" VALUES(1359,33,NULL,'2026-10-29 13:06:40.563957');
INSERT INTO "document_views" VALUES(1360,33,NULL,'2026-10-19 10:23:40.563957');
INSERT INTO "document_views" VALUES(1361,34,NULL,'2026-10-25 23:56:40.563957');
INSERT INTO "document_views" VALUES(1362,34,NULL,'2026-10-17 02:02:40.563957');
INSERT INTO "document_views" VALUES(1363,34,NULL,'2026-10-04 10:11:40.563957');
INSERT INTO "document_views" VALUES(1364,34,NULL,'2026-10-14 23:48:40.563957');
INSERT INTO "document_views" VALUES(1365,34,NULL,'2026-10-31 03:47:40.563957');
INSERT INTO "document_views" VALUES(1366,34,NULL,'2026-10-30 03:00:40.563957');
INSERT INTO "document_views" VALUES(1367,34,NULL,'2026-10-18 18:06:40.563957');
INSERT INTO "document_views" VALUES(1368,34,NULL,'2026-10-25 16:33:40.563957');
INSERT INTO "document_views" VALUES(1369,34,NULL,'2026-10-27 02:26:40.563957');
INSERT INTO "document_views" VALUES(1370,34,NULL,'2026-10-27 09:12:40.563957');
INSERT INTO "document_views" VALUES(1371,34,NULL,'2026-10-30 12:19:40.563957');
INSERT INTO "document_views" VALUES(1372,35,NULL,'2026-10-17 07:38:40.563957');
INSERT INTO "document_views" VALUES(1373,35,NULL,'2026-10-30 08:44:40.563957');
INSERT INTO "document_views" VALUES(1374,35,NULL,'2026-10-07 00:12:40.563957');
INSERT INTO "document_views" VALUES(1375,35,NULL,'2026-10-20 13:49:40.563957');
INSERT INTO "document_views" VALUES(1376,35,NULL,'2026-10-28 17:50:40.563957');
INSERT INTO "document_views" VALUES(1377,35,NULL,'2026-10-27 05:21:40.563957');
INSERT INTO "document_views" VALUES(1378,35,NULL,'2026-10-10 23:02:40.563957');
INSERT INTO "document_views" VALUES(1379,35,NULL,'2026-10-22 03:22:40.563957');
INSERT INTO "document_views" VALUES(1380,35,NULL,'2026-10-27 09:26:40.563957');
INSERT INTO "document_views" VALUES(1381,35,NULL,'2026-10-17 13:11:40.563957');
INSERT INTO "document_views" VALUES(1382,35,NULL,'2026-10-07 06:48:40.563957');
INSERT INTO "document_views" VALUES(1383,35,NULL,'2026-10-01 20:24:40.563957');
INSERT INTO "document_views" VALUES(1384,35,NULL,'2026-10-29 11:48:40.563957');
INSERT INTO "document_views" VALUES(1385,35,NULL,'2026-10-23 12:34:40.563957');
INSERT INTO "document_views" VALUES(1386,35,NULL,'2026-10-14 15:08:40.563957');
INSERT INTO "document_views" VALUES(1387,35,NULL,'2026-10-04 04:43:40.563957');
INSERT INTO "document_views" VALUES(1388,35,NULL,'2026-10-31 04:54:40.563957');
INSERT INTO "document_views" VALUES(1389,35,NULL,'2026-10-30 23:51:40.563957');
INSERT INTO "document_views" VALUES(1390,35,NULL,'2026-10-31 05:09:40.563957');
INSERT INTO "document_views" VALUES(1391,35,NULL,'2026-10-03 17:37:40.563957');
INSERT INTO "document_views" VALUES(1392,35,NULL,'2026-10-20 09:45:40.563957');
INSERT INTO "document_views" VALUES(1393,35,NULL,'2026-10-13 17:02:40.563957');
INSERT INTO "document_views" VALUES(1394,35,NULL,'2026-10-23 17:29:40.563957');
INSERT INTO "document_views" VALUES(1395,35,NULL,'2026-10-30 12:54:40.563957');
INSERT INTO "document_views" VALUES(1396,35,NULL,'2026-10-20 02:00:40.563957');
INSERT INTO "document_views" VALUES(1397,35,NULL,'2026-10-27 20:38:40.563957');
INSERT INTO "document_views" VALUES(1398,35,NULL,'2026-10-31 00:16:40.563957');
INSERT INTO "document_views" VALUES(1399,35,NULL,'2026-10-03 01:54:40.563957');
INSERT INTO "document_views" VALUES(1400,35,NULL,'2026-10-19 17:52:40.563957');
INSERT INTO "document_views" VALUES(1401,35,NULL,'2026-10-18 09:02:40.563957');
INSERT INTO "document_views" VALUES(1402,35,NULL,'2026-10-15 04:57:40.563957');
INSERT INTO "document_views" VALUES(1403,35,NULL,'2026-10-26 16:17:40.563957');
INSERT INTO "document_views" VALUES(1404,35,NULL,'2026-10-12 23:04:40.563957');
INSERT INTO "document_views" VALUES(1405,35,NULL,'2026-10-31 04:16:40.563957');
INSERT INTO "document_views" VALUES(1406,35,NULL,'2026-10-05 03:15:40.563957');
INSERT INTO "document_views" VALUES(1407,35,NULL,'2026-10-22 10:26:40.563957');
INSERT INTO "document_views" VALUES(1408,35,NULL,'2026-10-30 08:28:40.563957');
INSERT INTO "document_views" VALUES(1409,35,NULL,'2026-10-13 01:13:40.563957');
INSERT INTO "document_views" VALUES(1410,35,NULL,'2026-10-30 02:31:40.563957');
INSERT INTO "document_views" VALUES(1411,35,NULL,'2026-10-14 01:37:40.563957');
INSERT INTO "document_views" VALUES(1412,35,NULL,'2026-10-21 19:22:40.563957');
INSERT INTO "document_views" VALUES(1413,35,NULL,'2026-10-20 22:22:40.563957');
INSERT INTO "document_views" VALUES(1414,35,NULL,'2026-10-30 02:53:40.563957');
INSERT INTO "document_views" VALUES(1415,35,NULL,'2026-10-12 22:02:40.563957');
INSERT INTO "document_views" VALUES(1416,35,NULL,'2026-10-13 03:11:40.563957');
INSERT INTO "document_views" VALUES(1417,35,NULL,'2026-10-12 06:12:40.563957');
INSERT INTO "document_views" VALUES(1418,35,NULL,'2026-10-25 16:33:40.563957');
INSERT INTO "document_views" VALUES(1419,35,NULL,'2026-10-28 05:02:40.563957');
INSERT INTO "document_views" VALUES(1420,35,NULL,'2026-10-27 11:32:40.563957');
INSERT INTO "document_views" VALUES(1421,35,NULL,'2026-10-16 14:16:40.563957');
INSERT INTO "document_views" VALUES(1422,35,NULL,'2026-10-22 18:55:40.563957');
INSERT INTO "document_views" VALUES(1423,35,NULL,'2026-10-30 11:52:40.563957');
INSERT INTO "document_views" VALUES(1424,35,NULL,'2026-10-30 01:50:40.563957');
INSERT INTO "document_views" VALUES(1425,35,NULL,'2026-10-28 03:42:40.563957');
INSERT INTO "document_views" VALUES(1426,35,NULL,'2026-10-05 08:12:40.563957');
INSERT INTO "document_views" VALUES(1427,35,NULL,'2026-10-13 23:25:40.563957');
INSERT INTO "document_views" VALUES(1428,35,NULL,'2026-10-13 07:07:40.563957');
INSERT INTO "document_views" VALUES(1429,35,NULL,'2026-10-31 06:47:40.563957');
INSERT INTO "document_views" VALUES(1430,36,NULL,'2026-10-26 02:05:40.563957');
INSERT INTO "document_views" VALUES(1431,36,NULL,'2026-10-30 06:00:40.563957');
INSERT INTO "document_views" VALUES(1432,36,NULL,'2026-10-19 08:50:40.563957');
INSERT INTO "document_views" VALUES(1433,36,NULL,'2026-10-23 20:13:40.563957');
INSERT INTO "document_views" VALUES(1434,36,NULL,'2026-10-27 20:17:40.563957');
INSERT INTO "document_views" VALUES(1435,36,NULL,'2026-10-28 04:33:40.563957');
INSERT INTO "document_views" VALUES(1436,36,NULL,'2026-10-19 03:08:40.563957');
INSERT INTO "document_views" VALUES(1437,36,NULL,'2026-10-22 05:25:40.563957');
INSERT INTO "document_views" VALUES(1438,37,NULL,'2026-10-21 05:38:40.563957');
INSERT INTO "document_views" VALUES(1439,37,NULL,'2026-10-04 04:51:40.563957');
INSERT INTO "document_views" VALUES(1440,37,NULL,'2026-10-06 21:34:40.563957');
INSERT INTO "document_views" VALUES(1441,37,NULL,'2026-10-11 20:36:40.563957');
INSERT INTO "document_views" VALUES(1442,37,NULL,'2026-10-25 12:20:40.563957');
INSERT INTO "document_views" VALUES(1443,37,NULL,'2026-10-22 18:37:40.563957');
INSERT INTO "document_views" VALUES(1444,37,NULL,'2026-10-28 11:58:40.563957');
INSERT INTO "document_views" VALUES(1445,37,NULL,'2026-10-10 09:57:40.563957');
INSERT INTO "document_views" VALUES(1446,37,NULL,'2026-10-27 18:38:40.563957');
INSERT INTO "document_views" VALUES(1447,37,NULL,'2026-10-18 14:22:40.563957');
INSERT INTO "document_views" VALUES(1448,37,NULL,'2026-10-02 00:32:40.563957');
INSERT INTO "document_views" VALUES(1449,37,NULL,'2026-10-12 12:33:40.563957');
INSERT INTO "document_views" VALUES(1450,37,NULL,'2026-10-11 22:50:40.563957');
INSERT INTO "document_views" VALUES(1451,37,NULL,'2026-10-29 17:13:40.563957');
INSERT INTO "document_views" VALUES(1452,38,NULL,'2026-10-25 07:32:40.563957');
INSERT INTO "document_views" VALUES(1453,38,NULL,'2026-10-06 19:46:40.563957');
INSERT INTO "document_views" VALUES(1454,38,NULL,'2026-10-30 08:46:40.563957');
INSERT INTO "document_views" VALUES(1455,38,NULL,'2026-10-24 20:43:40.563957');
INSERT INTO "document_views" VALUES(1456,38,NULL,'2026-10-30 13:07:40.563957');
INSERT INTO "document_views" VALUES(1457,38,NULL,'2026-10-01 16:53:40.563957');
INSERT INTO "document_views" VALUES(1458,38,NULL,'2026-10-22 05:10:40.563957');
INSERT INTO "document_views" VALUES(1459,38,NULL,'2026-10-03 02:21:40.563957');
INSERT INTO "document_views" VALUES(1460,38,NULL,'2026-10-14 04:02:40.563957');
INSERT INTO "document_views" VALUES(1461,38,NULL,'2026-10-30 23:18:40.563957');
INSERT INTO "document_views" VALUES(1462,38,NULL,'2026-10-05 13:28:40.563957');
INSERT INTO "document_views" VALUES(1463,38,NULL,'2026-10-23 18:30:40.563957');
INSERT INTO "document_views" VALUES(1464,38,NULL,'2026-10-23 04:19:40.563957');
INSERT INTO "document_views" VALUES(1465,38,NULL,'2026-10-18 13:57:40.563957');
INSERT INTO "document_views" VALUES(1466,38,NULL,'2026-10-29 17:45:40.563957');
INSERT INTO "document_views" VALUES(1467,39,NULL,'2026-10-30 08:36:40.563957');
INSERT INTO "document_views" VALUES(1468,39,NULL,'2026-10-02 23:08:40.563957');
INSERT INTO "document_views" VALUES(1469,39,NULL,'2026-10-26 20:27:40.563957');
INSERT INTO "document_views" VALUES(1470,39,NULL,'2026-10-04 17:48:40.563957');
INSERT INTO "document_views" VALUES(1471,39,NULL,'2026-10-14 20:04:40.563957');
INSERT INTO "document_views" VALUES(1472,39,NULL,'2026-10-26 21:56:40.563957');
INSERT INTO "document_views" VALUES(1473,39,NULL,'2026-10-29 00:17:40.563957');
INSERT INTO "document_views" VALUES(1474,39,NULL,'2026-10-29 11:15:40.563957');
INSERT INTO "document_views" VALUES(1475,39,NULL,'2026-10-31 03:36:40.563957');
INSERT INTO "document_views" VALUES(1476,39,NULL,'2026-10-29 15:18:40.563957');
INSERT INTO "document_views" VALUES(1477,39,NULL,'2026-10-27 03:05:40.563957');
INSERT INTO "document_views" VALUES(1478,39,NULL,'2026-10-20 00:07:40.563957');
INSERT INTO "document_views" VALUES(1479,39,NULL,'2026-10-22 15:24:40.563957');
INSERT INTO "document_views" VALUES(1480,39,NULL,'2026-10-28 03:07:40.563957');
INSERT INTO "document_views" VALUES(1481,39,NULL,'2026-10-30 07:47:40.563957');
INSERT INTO "document_views" VALUES(1482,39,NULL,'2026-10-26 07:25:40.563957');
INSERT INTO "document_views" VALUES(1483,39,NULL,'2026-10-17 23:52:40.563957');
INSERT INTO "document_views" VALUES(1484,39,NULL,'2026-10-08 20:01:40.563957');
INSERT INTO "document_views" VALUES(1485,39,NULL,'2026-10-29 22:44:40.563957');
INSERT INTO "document_views" VALUES(1486,39,NULL,'2026-10-02 17:41:40.563957');
INSERT INTO "document_views" VALUES(1487,39,NULL,'2026-10-20 08:06:40.563957');
INSERT INTO "document_views" VALUES(1488,39,NULL,'2026-10-27 01:16:40.563957');
INSERT INTO "document_views" VALUES(1489,39,NULL,'2026-10-30 17:24:40.563957');
INSERT INTO "document_views" VALUES(1490,39,NULL,'2026-10-07 12:14:40.563957');
INSERT INTO "document_views" VALUES(1491,39,NULL,'2026-10-12 22:41:40.563957');
INSERT INTO "document_views" VALUES(1492,39,NULL,'2026-10-31 03:44:40.563957');
INSERT INTO "document_views" VALUES(1493,39,NULL,'2026-10-10 02:26:40.563957');
INSERT INTO "document_views" VALUES(1494,39,NULL,'2026-10-30 05:06:40.563957');
INSERT INTO "document_views" VALUES(1495,39,NULL,'2026-10-08 23:37:40.563957');
INSERT INTO "document_views" VALUES(1496,39,NULL,'2026-10-29 17:32:40.563957');
INSERT INTO "document_views" VALUES(1497,39,NULL,'2026-10-24 09:42:40.563957');
INSERT INTO "document_views" VALUES(1498,39,NULL,'2026-10-04 04:20:40.563957');
INSERT INTO "document_views" VALUES(1499,39,NULL,'2026-10-18 22:22:40.563957');
INSERT INTO "document_views" VALUES(1500,39,NULL,'2026-10-05 04:39:40.563957');
INSERT INTO "document_views" VALUES(1501,39,NULL,'2026-10-31 05:00:40.563957');
INSERT INTO "document_views" VALUES(1502,39,NULL,'2026-10-28 09:10:40.563957');
INSERT INTO "document_views" VALUES(1503,39,NULL,'2026-10-23 02:49:40.563957');
INSERT INTO "document_views" VALUES(1504,39,NULL,'2026-10-30 19:53:40.563957');
INSERT INTO "document_views" VALUES(1505,39,NULL,'2026-10-29 15:28:40.563957');
INSERT INTO "document_views" VALUES(1506,39,NULL,'2026-10-30 11:37:40.563957');
INSERT INTO "document_views" VALUES(1507,39,NULL,'2026-10-23 17:44:40.563957');
INSERT INTO "document_views" VALUES(1508,39,NULL,'2026-10-21 18:09:40.563957');
INSERT INTO "document_views" VALUES(1509,39,NULL,'2026-10-15 01:19:40.563957');
INSERT INTO "document_views" VALUES(1510,39,NULL,'2026-10-26 00:49:40.563957');
INSERT INTO "document_views" VALUES(1511,39,NULL,'2026-10-27 15:59:40.563957');
INSERT INTO "document_views" VALUES(1512,39,NULL,'2026-10-07 06:02:40.563957');
INSERT INTO "document_views" VALUES(1513,39,NULL,'2026-10-17 10:09:40.563957');
INSERT INTO "document_views" VALUES(1514,39,NULL,'2026-10-27 21:08:40.563957');
INSERT INTO "document_views" VALUES(1515,39,NULL,'2026-10-21 12:25:40.563957');
INSERT INTO "document_views" VALUES(1516,39,NULL,'2026-10-22 04:13:40.563957');
INSERT INTO "document_views" VALUES(1517,39,NULL,'2026-10-28 02:31:40.563957');
INSERT INTO "document_views" VALUES(1518,39,NULL,'2026-10-23 09:16:40.563957');
INSERT INTO "document_views" VALUES(1519,39,NULL,'2026-10-06 13:16:40.563957');
INSERT INTO "document_views" VALUES(1520,39,NULL,'2026-10-27 12:39:40.563957');
INSERT INTO "document_views" VALUES(1521,39,NULL,'2026-10-10 18:09:40.563957');
INSERT INTO "document_views" VALUES(1522,39,NULL,'2026-10-10 18:57:40.563957');
INSERT INTO "document_views" VALUES(1523,39,NULL,'2026-10-21 14:40:40.563957');
INSERT INTO "document_views" VALUES(1524,40,NULL,'2026-10-21 17:57:40.563957');
INSERT INTO "document_views" VALUES(1525,40,NULL,'2026-10-28 06:19:40.563957');
INSERT INTO "document_views" VALUES(1526,40,NULL,'2026-10-26 23:44:40.563957');
INSERT INTO "document_views" VALUES(1527,40,NULL,'2026-10-30 21:37:40.563957');
INSERT INTO "document_views" VALUES(1528,40,NULL,'2026-10-30 15:06:40.563957');
INSERT INTO "document_views" VALUES(1529,40,NULL,'2026-10-20 11:16:40.563957');
INSERT INTO "document_views" VALUES(1530,40,NULL,'2026-10-02 01:46:40.563957');
INSERT INTO "document_views" VALUES(1531,40,NULL,'2026-10-30 08:47:40.563957');
INSERT INTO "document_views" VALUES(1532,40,NULL,'2026-10-27 13:00:40.563957');
INSERT INTO "document_views" VALUES(1533,40,NULL,'2026-10-10 05:18:40.563957');
INSERT INTO "document_views" VALUES(1534,40,NULL,'2026-10-11 23:43:40.563957');
INSERT INTO "document_views" VALUES(1535,40,NULL,'2026-10-18 17:57:40.563957');
INSERT INTO "document_views" VALUES(1536,40,NULL,'2026-10-26 01:17:40.563957');
INSERT INTO "document_views" VALUES(1537,40,NULL,'2026-10-29 10:59:40.563957');
INSERT INTO "document_views" VALUES(1538,40,NULL,'2026-10-26 07:24:40.563957');
INSERT INTO "document_views" VALUES(1539,40,NULL,'2026-10-25 11:01:40.563957');
INSERT INTO "document_views" VALUES(1540,40,NULL,'2026-10-30 07:18:40.563957');
INSERT INTO "document_views" VALUES(1541,40,NULL,'2026-10-25 11:50:40.563957');
INSERT INTO "document_views" VALUES(1542,40,NULL,'2026-10-19 11:59:40.563957');
INSERT INTO "document_views" VALUES(1543,40,NULL,'2026-10-03 14:24:40.563957');
INSERT INTO "document_views" VALUES(1544,40,NULL,'2026-10-20 01:13:40.563957');
INSERT INTO "document_views" VALUES(1545,40,NULL,'2026-10-22 04:08:40.563957');
INSERT INTO "document_views" VALUES(1546,40,NULL,'2026-10-30 10:40:40.563957');
INSERT INTO "document_views" VALUES(1547,40,NULL,'2026-10-28 13:14:40.563957');
INSERT INTO "document_views" VALUES(1548,40,NULL,'2026-10-21 19:53:40.563957');
INSERT INTO "document_views" VALUES(1549,40,NULL,'2026-10-05 00:20:40.563957');
INSERT INTO "document_views" VALUES(1550,40,NULL,'2026-10-09 19:35:40.563957');
INSERT INTO "document_views" VALUES(1551,40,NULL,'2026-10-13 20:10:40.563957');
INSERT INTO "document_views" VALUES(1552,40,NULL,'2026-10-31 02:10:40.563957');
INSERT INTO "document_views" VALUES(1553,40,NULL,'2026-10-19 02:22:40.563957');
INSERT INTO "document_views" VALUES(1554,40,NULL,'2026-10-11 13:15:40.563957');
INSERT INTO "document_views" VALUES(1555,40,NULL,'2026-10-08 04:44:40.563957');
INSERT INTO "document_views" VALUES(1556,40,NULL,'2026-10-24 08:36:40.563957');
INSERT INTO "document_views" VALUES(1557,40,NULL,'2026-10-25 03:46:40.563957');
INSERT INTO "document_views" VALUES(1558,40,NULL,'2026-10-25 20:12:40.563957');
INSERT INTO "document_views" VALUES(1559,40,NULL,'2026-10-30 01:50:40.563957');
INSERT INTO "document_views" VALUES(1560,40,NULL,'2026-10-12 16:18:40.563957');
INSERT INTO "document_views" VALUES(1561,40,NULL,'2026-10-10 14:35:40.563957');
INSERT INTO "document_views" VALUES(1562,40,NULL,'2026-10-16 01:16:40.563957');
INSERT INTO "document_views" VALUES(1563,40,NULL,'2026-10-13 12:02:40.563957');
INSERT INTO "document_views" VALUES(1564,40,NULL,'2026-10-14 10:16:40.563957');
INSERT INTO "document_views" VALUES(1565,40,NULL,'2026-10-10 23:35:40.563957');
INSERT INTO "document_views" VALUES(1566,40,NULL,'2026-10-16 01:13:40.563957');
INSERT INTO "document_views" VALUES(1567,40,NULL,'2026-10-24 07:42:40.563957');
INSERT INTO "document_views" VALUES(1568,40,NULL,'2026-10-27 01:09:40.563957');
INSERT INTO "document_views" VALUES(1569,40,NULL,'2026-10-12 07:15:40.563957');
INSERT INTO "document_views" VALUES(1570,40,NULL,'2026-10-03 17:51:40.563957');
INSERT INTO "document_views" VALUES(1571,40,NULL,'2026-10-07 11:50:40.563957');
INSERT INTO "document_views" VALUES(1572,40,NULL,'2026-10-30 10:39:40.563957');
INSERT INTO "document_views" VALUES(1573,40,NULL,'2026-10-26 10:20:40.563957');
INSERT INTO "document_views" VALUES(1574,40,NULL,'2026-10-28 11:54:40.563957');
INSERT INTO "document_views" VALUES(1575,40,NULL,'2026-10-30 14:16:40.563957');
INSERT INTO "document_views" VALUES(1576,40,NULL,'2026-10-30 04:33:40.563957');
INSERT INTO "document_views" VALUES(1577,40,NULL,'2026-10-27 20:18:40.563957');
INSERT INTO "document_views" VALUES(1578,40,NULL,'2026-10-30 04:11:40.563957');
INSERT INTO "document_views" VALUES(1579,40,NULL,'2026-10-09 08:20:40.563957');
INSERT INTO "document_views" VALUES(1580,40,NULL,'2026-10-16 19:45:40.563957');
INSERT INTO "document_views" VALUES(1581,40,NULL,'2026-10-22 22:09:40.563957');
INSERT INTO "document_views" VALUES(1582,40,NULL,'2026-10-28 07:33:40.563957');
INSERT INTO "document_views" VALUES(1583,40,NULL,'2026-10-30 22:27:40.563957');
INSERT INTO "document_views" VALUES(1584,40,NULL,'2026-10-11 07:10:40.563957');
INSERT INTO "document_views" VALUES(1585,40,NULL,'2026-10-30 16:15:40.563957');
INSERT INTO "document_views" VALUES(1586,40,NULL,'2026-10-13 01:32:40.563957');
INSERT INTO "document_views" VALUES(1587,40,NULL,'2026-10-06 14:23:40.563957');
INSERT INTO "document_views" VALUES(1588,40,NULL,'2026-10-06 19:13:40.563957');
INSERT INTO "document_views" VALUES(1589,40,NULL,'2026-10-20 03:45:40.563957');
INSERT INTO "document_views" VALUES(1590,40,NULL,'2026-10-08 11:29:40.563957');
INSERT INTO "document_views" VALUES(1591,40,NULL,'2026-10-15 07:45:40.563957');
INSERT INTO "document_views" VALUES(1592,40,NULL,'2026-10-28 15:48:40.563957');
INSERT INTO "document_views" VALUES(1593,40,NULL,'2026-10-31 06:04:40.563957');
INSERT INTO "document_views" VALUES(1594,40,NULL,'2026-10-26 20:20:40.563957');
INSERT INTO "document_views" VALUES(1595,40,NULL,'2026-10-28 03:38:40.563957');
INSERT INTO "document_views" VALUES(1596,40,NULL,'2026-10-31 01:24:40.563957');
INSERT INTO "document_views" VALUES(1597,40,NULL,'2026-10-07 01:43:40.563957');
INSERT INTO "document_views" VALUES(1598,40,NULL,'2026-10-12 12:32:40.563957');
INSERT INTO "document_views" VALUES(1599,40,NULL,'2026-10-04 04:02:40.563957');
INSERT INTO "document_views" VALUES(1600,40,NULL,'2026-10-25 10:16:40.563957');
INSERT INTO "document_views" VALUES(1601,40,NULL,'2026-10-06 06:09:40.563957');
INSERT INTO "document_views" VALUES(1602,40,NULL,'2026-10-23 08:54:40.563957');
INSERT INTO "document_views" VALUES(1603,40,NULL,'2026-10-29 16:23:40.563957');
INSERT INTO "document_views" VALUES(1604,40,NULL,'2026-10-30 03:45:40.563957');
INSERT INTO "document_views" VALUES(1605,40,NULL,'2026-10-26 00:43:40.563957');
INSERT INTO "document_views" VALUES(1606,40,NULL,'2026-10-23 12:18:40.563957');
INSERT INTO "document_views" VALUES(1607,40,NULL,'2026-10-13 12:46:40.563957');
INSERT INTO "document_views" VALUES(1608,40,NULL,'2026-10-27 21:36:40.563957');
INSERT INTO "document_views" VALUES(1609,40,NULL,'2026-10-27 03:56:40.563957');
INSERT INTO "document_views" VALUES(1610,40,NULL,'2026-10-30 11:42:40.563957');
INSERT INTO "document_views" VALUES(1611,40,NULL,'2026-10-19 14:27:40.563957');
INSERT INTO "document_views" VALUES(1612,40,NULL,'2026-10-29 18:54:40.563957');
INSERT INTO "document_views" VALUES(1613,40,NULL,'2026-10-31 04:13:40.563957');
INSERT INTO "document_views" VALUES(1614,40,NULL,'2026-10-26 08:37:40.563957');
INSERT INTO "document_views" VALUES(1615,40,NULL,'2026-10-16 14:49:40.563957');
INSERT INTO "document_views" VALUES(1616,40,NULL,'2026-10-29 06:20:40.563957');
INSERT INTO "document_views" VALUES(1617,40,NULL,'2026-10-28 09:25:40.563957');
INSERT INTO "document_views" VALUES(1618,40,NULL,'2026-10-27 04:25:40.563957');
INSERT INTO "document_views" VALUES(1619,40,NULL,'2026-10-22 03:16:40.563957');
INSERT INTO "document_views" VALUES(1620,40,NULL,'2026-10-26 17:38:40.563957');
INSERT INTO "document_views" VALUES(1621,40,NULL,'2026-10-22 08:39:40.563957');
INSERT INTO "document_views" VALUES(1622,40,NULL,'2026-10-27 09:18:40.563957');
INSERT INTO "document_views" VALUES(1623,40,NULL,'2026-10-20 00:54:40.563957');
INSERT INTO "document_views" VALUES(1624,40,NULL,'2026-10-24 18:11:40.563957');
INSERT INTO "document_views" VALUES(1625,40,NULL,'2026-10-24 16:00:40.563957');
INSERT INTO "document_views" VALUES(1626,40,NULL,'2026-10-30 16:12:40.563957');
INSERT INTO "document_views" VALUES(1627,40,NULL,'2026-10-22 23:29:40.563957');
INSERT INTO "document_views" VALUES(1628,40,NULL,'2026-10-08 11:57:40.563957');
INSERT INTO "document_views" VALUES(1629,40,NULL,'2026-10-30 07:26:40.563957');
INSERT INTO "document_views" VALUES(1630,40,NULL,'2026-10-16 04:17:40.563957');
INSERT INTO "document_views" VALUES(1631,40,NULL,'2026-10-15 12:44:40.563957');
INSERT INTO "document_views" VALUES(1632,40,NULL,'2026-10-23 11:05:40.563957');
INSERT INTO "document_views" VALUES(1633,40,NULL,'2026-10-29 05:08:40.563957');
INSERT INTO "document_views" VALUES(1634,40,NULL,'2026-10-08 13:22:40.563957');
INSERT INTO "document_views" VALUES(1635,40,NULL,'2026-10-23 12:56:40.563957');
INSERT INTO "document_views" VALUES(1636,40,NULL,'2026-10-14 15:00:40.563957');
INSERT INTO "document_views" VALUES(1637,40,NULL,'2026-10-18 23:10:40.563957');
INSERT INTO "document_views" VALUES(1638,40,NULL,'2026-10-22 04:31:40.563957');
INSERT INTO "document_views" VALUES(1639,40,NULL,'2026-10-25 06:01:40.563957');
INSERT INTO "document_views" VALUES(1640,40,NULL,'2026-10-21 13:34:40.563957');
INSERT INTO "document_views" VALUES(1641,40,NULL,'2026-10-09 08:05:40.563957');
INSERT INTO "document_views" VALUES(1642,40,NULL,'2026-10-02 02:11:40.563957');
INSERT INTO "document_views" VALUES(1643,40,NULL,'2026-10-29 15:53:40.563957');
INSERT INTO "document_views" VALUES(1644,40,NULL,'2026-10-30 01:30:40.563957');
INSERT INTO "document_views" VALUES(1645,40,NULL,'2026-10-03 00:38:40.563957');
INSERT INTO "document_views" VALUES(1646,40,NULL,'2026-10-29 16:45:40.563957');
INSERT INTO "document_views" VALUES(1647,40,NULL,'2026-10-30 07:53:40.563957');
INSERT INTO "document_views" VALUES(1648,41,NULL,'2026-10-10 02:10:40.563957');
INSERT INTO "document_views" VALUES(1649,41,NULL,'2026-10-08 22:24:40.563957');
INSERT INTO "document_views" VALUES(1650,41,NULL,'2026-10-27 04:55:40.563957');
INSERT INTO "document_views" VALUES(1651,41,NULL,'2026-10-30 12:13:40.563957');
INSERT INTO "document_views" VALUES(1652,41,NULL,'2026-10-24 20:05:40.563957');
INSERT INTO "document_views" VALUES(1653,41,NULL,'2026-10-07 13:28:40.563957');
INSERT INTO "document_views" VALUES(1654,41,NULL,'2026-10-23 06:47:40.563957');
INSERT INTO "document_views" VALUES(1655,41,NULL,'2026-10-10 09:56:40.563957');
INSERT INTO "document_views" VALUES(1656,41,NULL,'2026-10-18 16:53:40.563957');
INSERT INTO "document_views" VALUES(1657,41,NULL,'2026-10-31 02:06:40.563957');
INSERT INTO "document_views" VALUES(1658,41,NULL,'2026-10-29 11:08:40.563957');
INSERT INTO "document_views" VALUES(1659,41,NULL,'2026-10-19 03:47:40.563957');
INSERT INTO "document_views" VALUES(1660,41,NULL,'2026-10-04 12:00:40.563957');
INSERT INTO "document_views" VALUES(1661,42,NULL,'2026-10-07 19:28:40.563957');
INSERT INTO "document_views" VALUES(1662,42,NULL,'2026-10-06 22:12:40.563957');
INSERT INTO "document_views" VALUES(1663,42,NULL,'2026-10-24 14:38:40.563957');
INSERT INTO "document_views" VALUES(1664,42,NULL,'2026-10-18 15:04:40.563957');
INSERT INTO "document_views" VALUES(1665,42,NULL,'2026-10-30 21:48:40.563957');
INSERT INTO "document_views" VALUES(1666,42,NULL,'2026-10-23 10:06:40.563957');
INSERT INTO "document_views" VALUES(1667,42,NULL,'2026-10-17 07:32:40.563957');
INSERT INTO "document_views" VALUES(1668,42,NULL,'2026-10-24 17:42:40.563957');
INSERT INTO "document_views" VALUES(1669,42,NULL,'2026-10-06 19:54:40.563957');
INSERT INTO "document_views" VALUES(1670,42,NULL,'2026-10-15 05:32:40.563957');
INSERT INTO "document_views" VALUES(1671,42,NULL,'2026-10-12 22:02:40.563957');
INSERT INTO "document_views" VALUES(1672,42,NULL,'2026-10-06 06:31:40.563957');
INSERT INTO "document_views" VALUES(1673,42,NULL,'2026-10-25 20:52:40.563957');
INSERT INTO "document_views" VALUES(1674,42,NULL,'2026-10-26 14:26:40.563957');
INSERT INTO "document_views" VALUES(1675,42,NULL,'2026-10-07 07:50:40.563957');
INSERT INTO "document_views" VALUES(1676,42,NULL,'2026-10-30 23:26:40.563957');
INSERT INTO "document_views" VALUES(1677,42,NULL,'2026-10-29 16:05:40.563957');
INSERT INTO "document_views" VALUES(1678,42,NULL,'2026-10-11 20:15:40.563957');
INSERT INTO "document_views" VALUES(1679,42,NULL,'2026-10-27 16:59:40.563957');
INSERT INTO "document_views" VALUES(1680,42,NULL,'2026-10-18 04:10:40.563957');
INSERT INTO "document_views" VALUES(1681,42,NULL,'2026-10-29 00:00:40.563957');
INSERT INTO "document_views" VALUES(1682,42,NULL,'2026-10-05 17:19:40.563957');
INSERT INTO "document_views" VALUES(1683,42,NULL,'2026-10-12 13:35:40.563957');
INSERT INTO "document_views" VALUES(1684,42,NULL,'2026-10-08 05:17:40.563957');
INSERT INTO "document_views" VALUES(1685,42,NULL,'2026-10-21 01:47:40.563957');
INSERT INTO "document_views" VALUES(1686,42,NULL,'2026-10-30 13:55:40.563957');
INSERT INTO "document_views" VALUES(1687,42,NULL,'2026-10-23 13:19:40.563957');
INSERT INTO "document_views" VALUES(1688,42,NULL,'2026-10-07 06:13:40.563957');
INSERT INTO "document_views" VALUES(1689,42,NULL,'2026-10-30 00:21:40.563957');
INSERT INTO "document_views" VALUES(1690,42,NULL,'2026-10-08 22:42:40.563957');
INSERT INTO "document_views" VALUES(1691,42,NULL,'2026-10-31 05:29:40.563957');
INSERT INTO "document_views" VALUES(1692,42,NULL,'2026-10-05 00:25:40.563957');
INSERT INTO "document_views" VALUES(1693,42,NULL,'2026-10-27 15:22:40.563957');
INSERT INTO "document_views" VALUES(1694,42,NULL,'2026-10-20 09:31:40.563957');
INSERT INTO "document_views" VALUES(1695,42,NULL,'2026-10-04 07:57:40.563957');
INSERT INTO "document_views" VALUES(1696,42,NULL,'2026-10-30 18:30:40.563957');
INSERT INTO "document_views" VALUES(1697,42,NULL,'2026-10-21 15:59:40.563957');
INSERT INTO "document_views" VALUES(1698,42,NULL,'2026-10-29 15:01:40.563957');
INSERT INTO "document_views" VALUES(1699,42,NULL,'2026-10-18 19:16:40.563957');
INSERT INTO "document_views" VALUES(1700,42,NULL,'2026-10-25 22:23:40.563957');
INSERT INTO "document_views" VALUES(1701,42,NULL,'2026-10-12 07:42:40.563957');
INSERT INTO "document_views" VALUES(1702,42,NULL,'2026-10-31 06:16:40.563957');
INSERT INTO "document_views" VALUES(1703,42,NULL,'2026-10-25 01:39:40.563957');
INSERT INTO "document_views" VALUES(1704,42,NULL,'2026-10-07 23:54:40.563957');
INSERT INTO "document_views" VALUES(1705,42,NULL,'2026-10-07 09:07:40.563957');
INSERT INTO "document_views" VALUES(1706,42,NULL,'2026-10-29 00:09:40.563957');
INSERT INTO "document_views" VALUES(1707,42,NULL,'2026-10-27 17:14:40.563957');
INSERT INTO "document_views" VALUES(1708,42,NULL,'2026-10-20 07:55:40.563957');
INSERT INTO "document_views" VALUES(1709,42,NULL,'2026-10-31 02:42:40.563957');
INSERT INTO "document_views" VALUES(1710,42,NULL,'2026-10-16 10:41:40.563957');
INSERT INTO "document_views" VALUES(1711,42,NULL,'2026-10-09 23:34:40.563957');
INSERT INTO "document_views" VALUES(1712,42,NULL,'2026-10-27 20:47:40.563957');
INSERT INTO "document_views" VALUES(1713,42,NULL,'2026-10-13 09:16:40.563957');
INSERT INTO "document_views" VALUES(1714,42,NULL,'2026-10-27 18:21:40.563957');
INSERT INTO "document_views" VALUES(1715,42,NULL,'2026-10-07 15:32:40.563957');
INSERT INTO "document_views" VALUES(1716,42,NULL,'2026-10-27 15:17:40.563957');
INSERT INTO "document_views" VALUES(1717,42,NULL,'2026-10-26 13:26:40.563957');
INSERT INTO "document_views" VALUES(1718,42,NULL,'2026-10-08 17:39:40.563957');
INSERT INTO "document_views" VALUES(1719,42,NULL,'2026-10-19 06:57:40.563957');
INSERT INTO "document_views" VALUES(1720,42,NULL,'2026-10-20 08:36:40.563957');
INSERT INTO "document_views" VALUES(1721,42,NULL,'2026-10-02 18:26:40.563957');
INSERT INTO "document_views" VALUES(1722,42,NULL,'2026-10-19 10:56:40.563957');
INSERT INTO "document_views" VALUES(1723,42,NULL,'2026-10-17 21:01:40.563957');
INSERT INTO "document_views" VALUES(1724,42,NULL,'2026-10-14 14:46:40.563957');
INSERT INTO "document_views" VALUES(1725,42,NULL,'2026-10-30 21:46:40.563957');
INSERT INTO "document_views" VALUES(1726,42,NULL,'2026-10-16 21:45:40.563957');
INSERT INTO "document_views" VALUES(1727,42,NULL,'2026-10-27 08:58:40.563957');
INSERT INTO "document_views" VALUES(1728,42,NULL,'2026-10-27 02:05:40.563957');
INSERT INTO "document_views" VALUES(1729,42,NULL,'2026-10-20 23:00:40.563957');
INSERT INTO "document_views" VALUES(1730,42,NULL,'2026-10-05 10:44:40.563957');
INSERT INTO "document_views" VALUES(1731,42,NULL,'2026-10-23 20:18:40.563957');
INSERT INTO "document_views" VALUES(1732,42,NULL,'2026-10-15 06:20:40.563957');
INSERT INTO "document_views" VALUES(1733,42,NULL,'2026-10-15 21:07:40.563957');
INSERT INTO "document_views" VALUES(1734,42,NULL,'2026-10-27 16:55:40.563957');
INSERT INTO "document_views" VALUES(1735,42,NULL,'2026-10-24 06:00:40.563957');
INSERT INTO "document_views" VALUES(1736,42,NULL,'2026-10-18 11:41:40.563957');
INSERT INTO "document_views" VALUES(1737,42,NULL,'2026-10-09 19:30:40.563957');
INSERT INTO "document_views" VALUES(1738,42,NULL,'2026-10-13 23:37:40.563957');
INSERT INTO "document_views" VALUES(1739,42,NULL,'2026-10-14 09:25:40.563957');
INSERT INTO "document_views" VALUES(1740,42,NULL,'2026-10-10 08:17:40.563957');
INSERT INTO "document_views" VALUES(1741,42,NULL,'2026-10-25 20:58:40.563957');
INSERT INTO "document_views" VALUES(1742,42,NULL,'2026-10-08 08:46:40.563957');
INSERT INTO "document_views" VALUES(1743,42,NULL,'2026-10-07 01:02:40.563957');
INSERT INTO "document_views" VALUES(1744,42,NULL,'2026-10-26 15:08:40.563957');
INSERT INTO "document_views" VALUES(1745,42,NULL,'2026-10-29 22:23:40.563957');
INSERT INTO "document_views" VALUES(1746,42,NULL,'2026-10-13 12:08:40.563957');
INSERT INTO "document_views" VALUES(1747,42,NULL,'2026-10-12 00:58:40.563957');
INSERT INTO "document_views" VALUES(1748,42,NULL,'2026-10-03 19:45:40.563957');
INSERT INTO "document_views" VALUES(1749,42,NULL,'2026-10-15 23:37:40.563957');
INSERT INTO "document_views" VALUES(1750,42,NULL,'2026-10-25 20:44:40.563957');
INSERT INTO "document_views" VALUES(1751,42,NULL,'2026-10-23 19:54:40.563957');
INSERT INTO "document_views" VALUES(1752,42,NULL,'2026-10-24 11:13:40.563957');
INSERT INTO "document_views" VALUES(1753,42,NULL,'2026-10-27 03:11:40.563957');
INSERT INTO "document_views" VALUES(1754,42,NULL,'2026-10-22 09:33:40.563957');
INSERT INTO "document_views" VALUES(1755,43,NULL,'2026-10-17 15:05:40.563957');
INSERT INTO "document_views" VALUES(1756,43,NULL,'2026-10-06 14:08:40.563957');
INSERT INTO "document_views" VALUES(1757,43,NULL,'2026-10-29 07:58:40.563957');
INSERT INTO "document_views" VALUES(1758,43,NULL,'2026-10-24 21:01:40.563957');
INSERT INTO "document_views" VALUES(1759,43,NULL,'2026-10-24 02:04:40.563957');
INSERT INTO "document_views" VALUES(1760,43,NULL,'2026-10-30 00:22:40.563957');
INSERT INTO "document_views" VALUES(1761,43,NULL,'2026-10-25 11:46:40.563957');
INSERT INTO "document_views" VALUES(1762,43,NULL,'2026-10-05 15:35:40.563957');
INSERT INTO "document_views" VALUES(1763,43,NULL,'2026-10-30 01:03:40.563957');
INSERT INTO "document_views" VALUES(1764,43,NULL,'2026-10-10 14:34:40.563957');
INSERT INTO "document_views" VALUES(1765,43,NULL,'2026-10-26 01:10:40.563957');
INSERT INTO "document_views" VALUES(1766,43,NULL,'2026-10-27 05:14:40.563957');
INSERT INTO "document_views" VALUES(1767,43,NULL,'2026-10-30 21:52:40.563957');
INSERT INTO "document_views" VALUES(1768,43,NULL,'2026-10-29 01:27:40.563957');
INSERT INTO "document_views" VALUES(1769,43,NULL,'2026-10-19 01:48:40.563957');
INSERT INTO "document_views" VALUES(1770,43,NULL,'2026-10-22 04:12:40.563957');
INSERT INTO "document_views" VALUES(1771,43,NULL,'2026-10-29 16:24:40.563957');
INSERT INTO "document_views" VALUES(1772,43,NULL,'2026-10-16 17:26:40.563957');
INSERT INTO "document_views" VALUES(1773,43,NULL,'2026-10-23 14:55:40.563957');
INSERT INTO "document_views" VALUES(1774,43,NULL,'2026-10-25 05:55:40.563957');
INSERT INTO "document_views" VALUES(1775,43,NULL,'2026-10-20 18:28:40.563957');
INSERT INTO "document_views" VALUES(1776,43,NULL,'2026-10-03 20:13:40.563957');
INSERT INTO "document_views" VALUES(1777,43,NULL,'2026-10-11 13:05:40.563957');
INSERT INTO "document_views" VALUES(1778,43,NULL,'2026-10-28 08:07:40.563957');
INSERT INTO "document_views" VALUES(1779,43,NULL,'2026-10-30 22:43:40.563957');
INSERT INTO "document_views" VALUES(1780,43,NULL,'2026-10-28 19:27:40.563957');
INSERT INTO "document_views" VALUES(1781,43,NULL,'2026-10-27 03:42:40.563957');
INSERT INTO "document_views" VALUES(1782,43,NULL,'2026-10-24 11:07:40.563957');
INSERT INTO "document_views" VALUES(1783,43,NULL,'2026-10-27 04:59:40.563957');
INSERT INTO "document_views" VALUES(1784,43,NULL,'2026-10-08 21:02:40.563957');
INSERT INTO "document_views" VALUES(1785,43,NULL,'2026-10-03 15:39:40.563957');
INSERT INTO "document_views" VALUES(1786,43,NULL,'2026-10-12 10:51:40.563957');
INSERT INTO "document_views" VALUES(1787,43,NULL,'2026-10-20 16:24:40.563957');
INSERT INTO "document_views" VALUES(1788,43,NULL,'2026-10-07 02:38:40.563957');
INSERT INTO "document_views" VALUES(1789,43,NULL,'2026-10-25 14:29:40.563957');
INSERT INTO "document_views" VALUES(1790,43,NULL,'2026-10-26 00:47:40.563957');
INSERT INTO "document_views" VALUES(1791,43,NULL,'2026-10-29 17:26:40.563957');
INSERT INTO "document_views" VALUES(1792,43,NULL,'2026-10-30 23:33:40.563957');
INSERT INTO "document_views" VALUES(1793,43,NULL,'2026-10-13 02:44:40.563957');
INSERT INTO "document_views" VALUES(1794,43,NULL,'2026-10-29 06:28:40.563957');
INSERT INTO "document_views" VALUES(1795,43,NULL,'2026-10-19 01:26:40.563957');
INSERT INTO "document_views" VALUES(1796,43,NULL,'2026-10-29 09:00:40.563957');
INSERT INTO "document_views" VALUES(1797,43,NULL,'2026-10-10 18:24:40.563957');
INSERT INTO "document_views" VALUES(1798,43,NULL,'2026-10-06 22:29:40.563957');
INSERT INTO "document_views" VALUES(1799,43,NULL,'2026-10-11 09:56:40.563957');
INSERT INTO "document_views" VALUES(1800,43,NULL,'2026-10-31 05:34:40.563957');
INSERT INTO "document_views" VALUES(1801,43,NULL,'2026-10-15 08:54:40.563957');
INSERT INTO "document_views" VALUES(1802,43,NULL,'2026-10-09 05:34:40.563957');
INSERT INTO "document_views" VALUES(1803,43,NULL,'2026-10-14 16:59:40.563957');
INSERT INTO "document_views" VALUES(1804,43,NULL,'2026-10-23 02:59:40.563957');
INSERT INTO "document_views" VALUES(1805,43,NULL,'2026-10-19 15:01:40.563957');
INSERT INTO "document_views" VALUES(1806,43,NULL,'2026-10-14 00:12:40.563957');
INSERT INTO "document_views" VALUES(1807,43,NULL,'2026-10-14 09:42:40.563957');
INSERT INTO "document_views" VALUES(1808,43,NULL,'2026-10-30 16:51:40.563957');
INSERT INTO "document_views" VALUES(1809,43,NULL,'2026-10-15 08:36:40.563957');
INSERT INTO "document_views" VALUES(1810,44,NULL,'2026-10-18 02:32:40.563957');
INSERT INTO "document_views" VALUES(1811,44,NULL,'2026-10-24 03:38:40.563957');
INSERT INTO "document_views" VALUES(1812,44,NULL,'2026-10-20 10:07:40.563957');
INSERT INTO "document_views" VALUES(1813,44,NULL,'2026-10-31 03:19:40.563957');
INSERT INTO "document_views" VALUES(1814,44,NULL,'2026-10-10 14:13:40.563957');
INSERT INTO "document_views" VALUES(1815,44,NULL,'2026-10-29 00:23:40.563957');
INSERT INTO "document_views" VALUES(1816,44,NULL,'2026-10-10 13:21:40.563957');
INSERT INTO "document_views" VALUES(1817,44,NULL,'2026-10-02 18:59:40.563957');
INSERT INTO "document_views" VALUES(1818,44,NULL,'2026-10-13 21:08:40.563957');
INSERT INTO "document_views" VALUES(1819,44,NULL,'2026-10-29 12:30:40.563957');
INSERT INTO "document_views" VALUES(1820,44,NULL,'2026-10-22 00:07:40.563957');
INSERT INTO "document_views" VALUES(1821,44,NULL,'2026-10-14 14:48:40.563957');
INSERT INTO "document_views" VALUES(1822,44,NULL,'2026-10-26 07:07:40.563957');
INSERT INTO "document_views" VALUES(1823,44,NULL,'2026-10-31 04:10:40.563957');
INSERT INTO "document_views" VALUES(1824,44,NULL,'2026-10-05 11:37:40.563957');
INSERT INTO "document_views" VALUES(1825,44,NULL,'2026-10-16 02:07:40.563957');
INSERT INTO "document_views" VALUES(1826,44,NULL,'2026-10-03 13:45:40.563957');
INSERT INTO "document_views" VALUES(1827,44,NULL,'2026-10-31 03:45:40.563957');
INSERT INTO "document_views" VALUES(1828,45,NULL,'2026-10-22 21:06:40.563957');
INSERT INTO "document_views" VALUES(1829,45,NULL,'2026-10-28 05:30:40.563957');
INSERT INTO "document_views" VALUES(1830,45,NULL,'2026-10-31 01:15:40.563957');
INSERT INTO "document_views" VALUES(1831,45,NULL,'2026-10-06 21:17:40.563957');
INSERT INTO "document_views" VALUES(1832,45,NULL,'2026-10-25 08:06:40.563957');
INSERT INTO "document_views" VALUES(1833,45,NULL,'2026-10-27 03:15:40.563957');
INSERT INTO "document_views" VALUES(1834,45,NULL,'2026-10-31 05:39:40.563957');
INSERT INTO "document_views" VALUES(1835,45,NULL,'2026-10-31 02:29:40.563957');
INSERT INTO "document_views" VALUES(1836,45,NULL,'2026-10-16 01:23:40.563957');
INSERT INTO "document_views" VALUES(1837,45,NULL,'2026-10-25 16:16:40.563957');
INSERT INTO "document_views" VALUES(1838,45,NULL,'2026-10-03 22:03:40.563957');
INSERT INTO "document_views" VALUES(1839,45,NULL,'2026-10-07 04:02:40.563957');
INSERT INTO "document_views" VALUES(1840,45,NULL,'2026-10-24 19:31:40.563957');
INSERT INTO "document_views" VALUES(1841,45,NULL,'2026-10-29 17:32:40.563957');
INSERT INTO "document_views" VALUES(1842,45,NULL,'2026-10-24 15:38:40.563957');
INSERT INTO "document_views" VALUES(1843,45,NULL,'2026-10-27 18:03:40.563957');
INSERT INTO "document_views" VALUES(1844,45,NULL,'2026-10-14 14:53:40.563957');
INSERT INTO "document_views" VALUES(1845,45,NULL,'2026-10-10 09:04:40.563957');
INSERT INTO "document_views" VALUES(1846,45,NULL,'2026-10-07 01:31:40.563957');
INSERT INTO "document_views" VALUES(1847,45,NULL,'2026-10-30 07:27:40.563957');
INSERT INTO "document_views" VALUES(1848,45,NULL,'2026-10-14 01:46:40.563957');
INSERT INTO "document_views" VALUES(1849,45,NULL,'2026-10-30 11:03:40.563957');
INSERT INTO "document_views" VALUES(1850,45,NULL,'2026-10-21 11:47:40.563957');
INSERT INTO "document_views" VALUES(1851,45,NULL,'2026-10-15 01:01:40.563957');
INSERT INTO "document_views" VALUES(1852,45,NULL,'2026-10-17 18:58:40.563957');
INSERT INTO "document_views" VALUES(1853,45,NULL,'2026-10-17 07:51:40.563957');
INSERT INTO "document_views" VALUES(1854,45,NULL,'2026-10-07 02:45:40.563957');
INSERT INTO "document_views" VALUES(1855,45,NULL,'2026-10-21 14:33:40.563957');
INSERT INTO "document_views" VALUES(1856,45,NULL,'2026-10-30 17:10:40.563957');
INSERT INTO "document_views" VALUES(1857,45,NULL,'2026-10-23 05:03:40.563957');
INSERT INTO "document_views" VALUES(1858,45,NULL,'2026-10-27 20:29:40.563957');
INSERT INTO "document_views" VALUES(1859,45,NULL,'2026-10-30 08:04:40.563957');
INSERT INTO "document_views" VALUES(1860,45,NULL,'2026-10-20 11:32:40.563957');
INSERT INTO "document_views" VALUES(1861,45,NULL,'2026-10-13 23:34:40.563957');
INSERT INTO "document_views" VALUES(1862,45,NULL,'2026-10-02 08:21:40.563957');
INSERT INTO "document_views" VALUES(1863,45,NULL,'2026-10-06 13:29:40.563957');
INSERT INTO "document_views" VALUES(1864,45,NULL,'2026-10-20 07:18:40.563957');
INSERT INTO "document_views" VALUES(1865,45,NULL,'2026-10-17 16:26:40.563957');
INSERT INTO "document_views" VALUES(1866,45,NULL,'2026-10-15 22:43:40.563957');
INSERT INTO "document_views" VALUES(1867,45,NULL,'2026-10-21 08:33:40.563957');
INSERT INTO "document_views" VALUES(1868,45,NULL,'2026-10-14 18:04:40.563957');
INSERT INTO "document_views" VALUES(1869,45,NULL,'2026-10-29 12:09:40.563957');
INSERT INTO "document_views" VALUES(1870,45,NULL,'2026-10-06 10:17:40.563957');
INSERT INTO "document_views" VALUES(1871,45,NULL,'2026-10-30 09:15:40.563957');
INSERT INTO "document_views" VALUES(1872,45,NULL,'2026-10-04 13:57:40.563957');
INSERT INTO "document_views" VALUES(1873,45,NULL,'2026-10-07 14:17:40.563957');
INSERT INTO "document_views" VALUES(1874,45,NULL,'2026-10-08 04:39:40.563957');
INSERT INTO "document_views" VALUES(1875,45,NULL,'2026-10-12 20:16:40.563957');
INSERT INTO "document_views" VALUES(1876,45,NULL,'2026-10-27 21:43:40.563957');
INSERT INTO "document_views" VALUES(1877,45,NULL,'2026-10-30 23:36:40.563957');
INSERT INTO "document_views" VALUES(1878,45,NULL,'2026-10-19 18:17:40.563957');
INSERT INTO "document_views" VALUES(1879,45,NULL,'2026-10-23 23:11:40.563957');
INSERT INTO "document_views" VALUES(1880,45,NULL,'2026-10-30 16:03:40.563957');
INSERT INTO "document_views" VALUES(1881,45,NULL,'2026-10-09 15:55:40.563957');
INSERT INTO "document_views" VALUES(1882,45,NULL,'2026-10-30 14:12:40.563957');
INSERT INTO "document_views" VALUES(1883,45,NULL,'2026-10-23 03:09:40.563957');
INSERT INTO "document_views" VALUES(1884,45,NULL,'2026-10-01 08:54:40.563957');
INSERT INTO "document_views" VALUES(1885,45,NULL,'2026-10-30 17:26:40.563957');
INSERT INTO "document_views" VALUES(1886,45,NULL,'2026-10-23 12:11:40.563957');
INSERT INTO "document_views" VALUES(1887,45,NULL,'2026-10-20 04:06:40.563957');
INSERT INTO "document_views" VALUES(1888,45,NULL,'2026-10-10 10:05:40.563957');
INSERT INTO "document_views" VALUES(1889,45,NULL,'2026-10-16 13:51:40.563957');
INSERT INTO "document_views" VALUES(1890,45,NULL,'2026-10-19 08:52:40.563957');
INSERT INTO "document_views" VALUES(1891,45,NULL,'2026-10-15 19:34:40.563957');
INSERT INTO "document_views" VALUES(1892,45,NULL,'2026-10-26 05:21:40.563957');
INSERT INTO "document_views" VALUES(1893,45,NULL,'2026-10-09 15:42:40.563957');
INSERT INTO "document_views" VALUES(1894,46,NULL,'2026-10-17 15:04:40.563957');
INSERT INTO "document_views" VALUES(1895,46,NULL,'2026-10-13 18:48:40.563957');
INSERT INTO "document_views" VALUES(1896,46,NULL,'2026-10-14 03:19:40.563957');
INSERT INTO "document_views" VALUES(1897,46,NULL,'2026-10-30 08:43:40.563957');
INSERT INTO "document_views" VALUES(1898,46,NULL,'2026-10-28 19:33:40.563957');
INSERT INTO "document_views" VALUES(1899,46,NULL,'2026-10-25 09:35:40.563957');
INSERT INTO "document_views" VALUES(1900,46,NULL,'2026-10-02 21:15:40.563957');
INSERT INTO "document_views" VALUES(1901,46,NULL,'2026-10-19 18:27:40.563957');
INSERT INTO "document_views" VALUES(1902,46,NULL,'2026-10-14 05:39:40.563957');
INSERT INTO "document_views" VALUES(1903,46,NULL,'2026-10-05 14:24:40.563957');
INSERT INTO "document_views" VALUES(1904,46,NULL,'2026-10-29 17:14:40.563957');
INSERT INTO "document_views" VALUES(1905,46,NULL,'2026-10-30 10:21:40.563957');
INSERT INTO "document_views" VALUES(1906,46,NULL,'2026-10-29 03:05:40.563957');
INSERT INTO "document_views" VALUES(1907,46,NULL,'2026-10-04 17:48:40.563957');
INSERT INTO "document_views" VALUES(1908,46,NULL,'2026-10-29 00:42:40.563957');
INSERT INTO "document_views" VALUES(1909,46,NULL,'2026-10-14 03:32:40.563957');
INSERT INTO "document_views" VALUES(1910,46,NULL,'2026-10-12 05:37:40.563957');
INSERT INTO "document_views" VALUES(1911,46,NULL,'2026-10-04 08:16:40.563957');
INSERT INTO "document_views" VALUES(1912,46,NULL,'2026-10-18 15:50:40.563957');
INSERT INTO "document_views" VALUES(1913,46,NULL,'2026-10-22 11:06:40.563957');
INSERT INTO "document_views" VALUES(1914,46,NULL,'2026-10-04 02:37:40.563957');
INSERT INTO "document_views" VALUES(1915,46,NULL,'2026-10-03 07:04:40.563957');
INSERT INTO "document_views" VALUES(1916,46,NULL,'2026-10-21 05:33:40.563957');
INSERT INTO "document_views" VALUES(1917,46,NULL,'2026-10-19 16:26:40.563957');
INSERT INTO "document_views" VALUES(1918,46,NULL,'2026-10-08 14:43:40.563957');
INSERT INTO "document_views" VALUES(1919,46,NULL,'2026-10-05 01:10:40.563957');
INSERT INTO "document_views" VALUES(1920,46,NULL,'2026-10-15 01:17:40.563957');
INSERT INTO "document_views" VALUES(1921,46,NULL,'2026-10-13 02:50:40.563957');
INSERT INTO "document_views" VALUES(1922,46,NULL,'2026-10-30 08:46:40.563957');
INSERT INTO "document_views" VALUES(1923,46,NULL,'2026-10-17 20:13:40.563957');
INSERT INTO "document_views" VALUES(1924,46,NULL,'2026-10-20 18:05:40.563957');
INSERT INTO "document_views" VALUES(1925,46,NULL,'2026-10-23 10:25:40.563957');
INSERT INTO "document_views" VALUES(1926,46,NULL,'2026-10-04 22:44:40.563957');
INSERT INTO "document_views" VALUES(1927,46,NULL,'2026-10-27 19:30:40.563957');
INSERT INTO "document_views" VALUES(1928,46,NULL,'2026-10-02 15:45:40.563957');
INSERT INTO "document_views" VALUES(1929,46,NULL,'2026-10-10 02:30:40.563957');
INSERT INTO "document_views" VALUES(1930,46,NULL,'2026-10-23 07:19:40.563957');
INSERT INTO "document_views" VALUES(1931,46,NULL,'2026-10-06 13:43:40.563957');
INSERT INTO "document_views" VALUES(1932,46,NULL,'2026-10-26 07:16:40.563957');
INSERT INTO "document_views" VALUES(1933,46,NULL,'2026-10-19 20:30:40.563957');
INSERT INTO "document_views" VALUES(1934,46,NULL,'2026-10-13 12:19:40.563957');
INSERT INTO "document_views" VALUES(1935,46,NULL,'2026-10-17 00:21:40.563957');
INSERT INTO "document_views" VALUES(1936,46,NULL,'2026-10-28 21:17:40.563957');
INSERT INTO "document_views" VALUES(1937,46,NULL,'2026-10-14 08:15:40.563957');
INSERT INTO "document_views" VALUES(1938,46,NULL,'2026-10-29 09:01:40.563957');
INSERT INTO "document_views" VALUES(1939,46,NULL,'2026-10-03 01:08:40.563957');
INSERT INTO "document_views" VALUES(1940,46,NULL,'2026-10-20 07:31:40.563957');
INSERT INTO "document_views" VALUES(1941,46,NULL,'2026-10-17 03:16:40.563957');
INSERT INTO "document_views" VALUES(1942,46,NULL,'2026-10-11 12:01:40.563957');
INSERT INTO "document_views" VALUES(1943,46,NULL,'2026-10-21 11:44:40.563957');
INSERT INTO "document_views" VALUES(1944,46,NULL,'2026-10-03 16:58:40.563957');
INSERT INTO "document_views" VALUES(1945,47,NULL,'2026-10-08 21:27:40.563957');
INSERT INTO "document_views" VALUES(1946,47,NULL,'2026-10-06 16:47:40.563957');
INSERT INTO "document_views" VALUES(1947,47,NULL,'2026-10-09 13:22:40.563957');
INSERT INTO "document_views" VALUES(1948,47,NULL,'2026-10-30 18:12:40.563957');
INSERT INTO "document_views" VALUES(1949,47,NULL,'2026-10-29 08:20:40.563957');
INSERT INTO "document_views" VALUES(1950,47,NULL,'2026-10-30 22:06:40.563957');
INSERT INTO "document_views" VALUES(1951,47,NULL,'2026-10-13 01:43:40.563957');
INSERT INTO "document_views" VALUES(1952,47,NULL,'2026-10-01 07:53:40.563957');
INSERT INTO "document_views" VALUES(1953,47,NULL,'2026-10-28 05:05:40.563957');
INSERT INTO "document_views" VALUES(1954,47,NULL,'2026-10-14 21:08:40.563957');
INSERT INTO "document_views" VALUES(1955,47,NULL,'2026-10-28 12:44:40.563957');
INSERT INTO "document_views" VALUES(1956,47,NULL,'2026-10-30 15:46:40.563957');
INSERT INTO "document_views" VALUES(1957,47,NULL,'2026-10-30 08:09:40.563957');
INSERT INTO "document_views" VALUES(1958,47,NULL,'2026-10-12 23:33:40.563957');
INSERT INTO "document_views" VALUES(1959,47,NULL,'2026-10-12 12:03:40.563957');
INSERT INTO "document_views" VALUES(1960,47,NULL,'2026-10-24 13:46:40.563957');
INSERT INTO "document_views" VALUES(1961,47,NULL,'2026-10-10 07:27:40.563957');
INSERT INTO "document_views" VALUES(1962,47,NULL,'2026-10-26 08:32:40.563957');
INSERT INTO "document_views" VALUES(1963,47,NULL,'2026-10-30 18:11:40.563957');
INSERT INTO "document_views" VALUES(1964,47,NULL,'2026-10-24 07:49:40.563957');
INSERT INTO "document_views" VALUES(1965,47,NULL,'2026-10-26 12:22:40.563957');
INSERT INTO "document_views" VALUES(1966,47,NULL,'2026-10-30 22:38:40.563957');
INSERT INTO "document_views" VALUES(1967,47,NULL,'2026-10-28 16:05:40.563957');
INSERT INTO "document_views" VALUES(1968,47,NULL,'2026-10-08 09:35:40.563957');
INSERT INTO "document_views" VALUES(1969,47,NULL,'2026-10-13 09:06:40.563957');
INSERT INTO "document_views" VALUES(1970,47,NULL,'2026-10-24 11:07:40.563957');
INSERT INTO "document_views" VALUES(1971,47,NULL,'2026-10-19 10:37:40.563957');
INSERT INTO "document_views" VALUES(1972,47,NULL,'2026-10-29 00:36:40.563957');
INSERT INTO "document_views" VALUES(1973,47,NULL,'2026-10-27 01:09:40.563957');
INSERT INTO "document_views" VALUES(1974,47,NULL,'2026-10-02 04:40:40.563957');
INSERT INTO "document_views" VALUES(1975,47,NULL,'2026-10-29 01:17:40.563957');
INSERT INTO "document_views" VALUES(1976,47,NULL,'2026-10-13 03:08:40.563957');
INSERT INTO "document_views" VALUES(1977,47,NULL,'2026-10-24 16:35:40.563957');
INSERT INTO "document_views" VALUES(1978,47,NULL,'2026-10-27 22:11:40.563957');
INSERT INTO "document_views" VALUES(1979,47,NULL,'2026-10-29 11:16:40.563957');
INSERT INTO "document_views" VALUES(1980,47,NULL,'2026-10-09 07:01:40.563957');
INSERT INTO "document_views" VALUES(1981,47,NULL,'2026-10-26 01:55:40.563957');
INSERT INTO "document_views" VALUES(1982,47,NULL,'2026-10-30 20:12:40.563957');
INSERT INTO "document_views" VALUES(1983,47,NULL,'2026-10-17 09:52:40.563957');
INSERT INTO "document_views" VALUES(1984,47,NULL,'2026-10-17 08:37:40.563957');
INSERT INTO "document_views" VALUES(1985,47,NULL,'2026-10-26 11:40:40.563957');
INSERT INTO "document_views" VALUES(1986,47,NULL,'2026-10-20 04:43:40.563957');
INSERT INTO "document_views" VALUES(1987,47,NULL,'2026-10-10 20:22:40.563957');
INSERT INTO "document_views" VALUES(1988,47,NULL,'2026-10-21 00:56:40.563957');
INSERT INTO "document_views" VALUES(1989,47,NULL,'2026-10-20 13:58:40.563957');
INSERT INTO "document_views" VALUES(1990,47,NULL,'2026-10-29 12:40:40.563957');
INSERT INTO "document_views" VALUES(1991,47,NULL,'2026-10-20 04:04:40.563957');
INSERT INTO "document_views" VALUES(1992,47,NULL,'2026-10-25 23:56:40.563957');
INSERT INTO "document_views" VALUES(1993,47,NULL,'2026-10-15 19:54:40.563957');
INSERT INTO "document_views" VALUES(1994,47,NULL,'2026-10-25 23:45:40.563957');
INSERT INTO "document_views" VALUES(1995,47,NULL,'2026-10-03 10:06:40.563957');
INSERT INTO "document_views" VALUES(1996,47,NULL,'2026-10-20 12:03:40.563957');
INSERT INTO "document_views" VALUES(1997,47,NULL,'2026-10-09 09:03:40.563957');
INSERT INTO "document_views" VALUES(1998,47,NULL,'2026-10-30 08:23:40.563957');
INSERT INTO "document_views" VALUES(1999,47,NULL,'2026-10-25 23:00:40.563957');
INSERT INTO "document_views" VALUES(2000,47,NULL,'2026-10-05 10:16:40.563957');
INSERT INTO "document_views" VALUES(2001,47,NULL,'2026-10-04 22:53:40.563957');
INSERT INTO "document_views" VALUES(2002,47,NULL,'2026-10-02 07:55:40.563957');
INSERT INTO "document_views" VALUES(2003,47,NULL,'2026-10-06 18:11:40.563957');
INSERT INTO "document_views" VALUES(2004,47,NULL,'2026-10-05 03:20:40.563957');
INSERT INTO "document_views" VALUES(2005,47,NULL,'2026-10-24 12:46:40.563957');
INSERT INTO "document_views" VALUES(2006,47,NULL,'2026-10-14 06:22:40.563957');
INSERT INTO "document_views" VALUES(2007,47,NULL,'2026-10-05 18:25:40.563957');
INSERT INTO "document_views" VALUES(2008,47,NULL,'2026-10-20 13:51:40.563957');
INSERT INTO "document_views" VALUES(2009,47,NULL,'2026-10-23 05:43:40.563957');
INSERT INTO "document_views" VALUES(2010,47,NULL,'2026-10-26 08:58:40.563957');
INSERT INTO "document_views" VALUES(2011,47,NULL,'2026-10-28 13:40:40.563957');
INSERT INTO "document_views" VALUES(2012,47,NULL,'2026-10-31 03:56:40.563957');
INSERT INTO "document_views" VALUES(2013,47,NULL,'2026-10-29 12:51:40.563957');
INSERT INTO "document_views" VALUES(2014,47,NULL,'2026-10-20 09:49:40.563957');
INSERT INTO "document_views" VALUES(2015,47,NULL,'2026-10-30 08:20:40.563957');
INSERT INTO "document_views" VALUES(2016,47,NULL,'2026-10-16 23:56:40.563957');
INSERT INTO "document_views" VALUES(2017,47,NULL,'2026-10-07 16:44:40.563957');
INSERT INTO "document_views" VALUES(2018,47,NULL,'2026-10-09 00:11:40.563957');
INSERT INTO "document_views" VALUES(2019,47,NULL,'2026-10-19 07:13:40.563957');
INSERT INTO "document_views" VALUES(2020,47,NULL,'2026-10-06 16:21:40.563957');
INSERT INTO "document_views" VALUES(2021,47,NULL,'2026-10-17 04:45:40.563957');
INSERT INTO "document_views" VALUES(2022,47,NULL,'2026-10-13 01:58:40.563957');
INSERT INTO "document_views" VALUES(2023,47,NULL,'2026-10-30 19:53:40.563957');
INSERT INTO "document_views" VALUES(2024,47,NULL,'2026-10-31 04:42:40.563957');
INSERT INTO "document_views" VALUES(2025,47,NULL,'2026-10-30 22:37:40.563957');
INSERT INTO "document_views" VALUES(2026,47,NULL,'2026-10-19 11:35:40.563957');
INSERT INTO "document_views" VALUES(2027,47,NULL,'2026-10-09 22:23:40.563957');
INSERT INTO "document_views" VALUES(2028,47,NULL,'2026-10-23 15:49:40.563957');
INSERT INTO "document_views" VALUES(2029,47,NULL,'2026-10-16 16:26:40.563957');
INSERT INTO "document_views" VALUES(2030,47,NULL,'2026-10-26 17:55:40.563957');
INSERT INTO "document_views" VALUES(2031,48,NULL,'2026-10-30 10:06:40.563957');
INSERT INTO "document_views" VALUES(2032,48,NULL,'2026-10-30 11:13:40.563957');
INSERT INTO "document_views" VALUES(2033,48,NULL,'2026-10-31 04:44:40.563957');
INSERT INTO "document_views" VALUES(2034,48,NULL,'2026-10-25 14:03:40.563957');
INSERT INTO "document_views" VALUES(2035,48,NULL,'2026-10-30 07:48:40.563957');
INSERT INTO "document_views" VALUES(2036,48,NULL,'2026-10-27 04:15:40.563957');
INSERT INTO "document_views" VALUES(2037,48,NULL,'2026-10-27 16:16:40.563957');
INSERT INTO "document_views" VALUES(2038,48,NULL,'2026-10-24 08:39:40.563957');
INSERT INTO "document_views" VALUES(2039,48,NULL,'2026-10-31 01:52:40.563957');
INSERT INTO "document_views" VALUES(2040,49,NULL,'2026-10-12 12:35:40.563957');
INSERT INTO "document_views" VALUES(2041,49,NULL,'2026-10-26 09:34:40.563957');
INSERT INTO "document_views" VALUES(2042,49,NULL,'2026-10-29 08:05:40.563957');
INSERT INTO "document_views" VALUES(2043,49,NULL,'2026-10-06 09:06:40.563957');
INSERT INTO "document_views" VALUES(2044,49,NULL,'2026-10-25 06:50:40.563957');
INSERT INTO "document_views" VALUES(2045,49,NULL,'2026-10-19 12:16:40.563957');
INSERT INTO "document_views" VALUES(2046,49,NULL,'2026-10-30 05:47:40.563957');
INSERT INTO "document_views" VALUES(2047,49,NULL,'2026-10-30 10:51:40.563957');
INSERT INTO "document_views" VALUES(2048,49,NULL,'2026-10-24 12:31:40.563957');
INSERT INTO "document_views" VALUES(2049,49,NULL,'2026-10-03 20:48:40.563957');
INSERT INTO "document_views" VALUES(2050,49,NULL,'2026-10-28 19:28:40.563957');
INSERT INTO "document_views" VALUES(2051,49,NULL,'2026-10-28 09:10:40.563957');
INSERT INTO "document_views" VALUES(2052,49,NULL,'2026-10-08 02:21:40.563957');
INSERT INTO "document_views" VALUES(2053,49,NULL,'2026-10-29 23:40:40.563957');
INSERT INTO "document_views" VALUES(2054,50,NULL,'2026-10-29 01:01:40.563957');
INSERT INTO "document_views" VALUES(2055,50,NULL,'2026-10-15 11:51:40.563957');
INSERT INTO "document_views" VALUES(2056,50,NULL,'2026-10-07 12:28:40.563957');
INSERT INTO "document_views" VALUES(2057,50,NULL,'2026-10-22 12:27:40.563957');
INSERT INTO "document_views" VALUES(2058,50,NULL,'2026-10-30 08:17:40.563957');
INSERT INTO "document_views" VALUES(2059,50,NULL,'2026-10-31 03:51:40.563957');
INSERT INTO "document_views" VALUES(2060,50,NULL,'2026-10-28 11:23:40.563957');
INSERT INTO "document_views" VALUES(2061,50,NULL,'2026-10-21 19:55:40.563957');
INSERT INTO "document_views" VALUES(2062,50,NULL,'2026-10-25 08:18:40.563957');
INSERT INTO "document_views" VALUES(2063,50,NULL,'2026-10-16 03:48:40.563957');
INSERT INTO "document_views" VALUES(2064,50,NULL,'2026-10-27 04:50:40.563957');
INSERT INTO "document_views" VALUES(2065,50,NULL,'2026-10-05 20:22:40.563957');
INSERT INTO "document_views" VALUES(2066,50,NULL,'2026-10-21 20:00:40.563957');
INSERT INTO "document_views" VALUES(2067,50,NULL,'2026-10-17 20:46:40.563957');
INSERT INTO "document_views" VALUES(2068,50,NULL,'2026-10-15 02:00:40.563957');
INSERT INTO "document_views" VALUES(2069,50,NULL,'2026-10-18 18:46:40.563957');
INSERT INTO "document_views" VALUES(2070,50,NULL,'2026-10-09 16:35:40.563957');
INSERT INTO "document_views" VALUES(2071,50,NULL,'2026-10-29 20:31:40.563957');
INSERT INTO "document_views" VALUES(2072,50,NULL,'2026-10-27 23:39:40.563957');
INSERT INTO "document_views" VALUES(2073,50,NULL,'2026-10-13 09:20:40.563957');
INSERT INTO "document_views" VALUES(2074,50,NULL,'2026-10-23 18:56:40.563957');
INSERT INTO "document_views" VALUES(2075,50,NULL,'2026-10-29 19:53:40.563957');
INSERT INTO "document_views" VALUES(2076,50,NULL,'2026-10-06 15:25:40.563957');
INSERT INTO "document_views" VALUES(2077,50,NULL,'2026-10-22 20:47:40.563957');
INSERT INTO "document_views" VALUES(2078,50,NULL,'2026-10-22 03:30:40.563957');
INSERT INTO "document_views" VALUES(2079,50,NULL,'2026-10-29 10:30:40.563957');
INSERT INTO "document_views" VALUES(2080,50,NULL,'2026-10-30 21:38:40.563957');
INSERT INTO "document_views" VALUES(2081,50,NULL,'2026-10-08 02:26:40.563957');
INSERT INTO "document_views" VALUES(2082,50,NULL,'2026-10-07 00:30:40.563957');
INSERT INTO "document_views" VALUES(2083,50,NULL,'2026-10-27 09:49:40.563957');
INSERT INTO "document_views" VALUES(2084,50,NULL,'2026-10-31 04:38:40.563957');
INSERT INTO "document_views" VALUES(2085,50,NULL,'2026-10-06 13:54:40.563957');
INSERT INTO "document_views" VALUES(2086,50,NULL,'2026-10-16 11:21:40.563957');
INSERT INTO "document_views" VALUES(2087,50,NULL,'2026-10-18 11:04:40.563957');
INSERT INTO "document_views" VALUES(2088,50,NULL,'2026-10-29 05:57:40.563957');
INSERT INTO "document_views" VALUES(2089,50,NULL,'2026-10-19 12:39:40.563957');
INSERT INTO "document_views" VALUES(2090,50,NULL,'2026-10-05 12:47:40.563957');
INSERT INTO "document_views" VALUES(2091,50,NULL,'2026-10-22 02:08:40.563957');
INSERT INTO "document_views" VALUES(2092,50,NULL,'2026-10-24 23:35:40.563957');
INSERT INTO "document_views" VALUES(2093,50,NULL,'2026-10-06 11:05:40.563957');
INSERT INTO "document_views" VALUES(2094,50,NULL,'2026-10-12 21:17:40.563957');
INSERT INTO "document_views" VALUES(2095,50,NULL,'2026-10-29 14:06:40.563957');
INSERT INTO "document_views" VALUES(2096,50,NULL,'2026-10-20 17:40:40.563957');
INSERT INTO "document_views" VALUES(2097,50,NULL,'2026-10-26 06:51:40.563957');
INSERT INTO "document_views" VALUES(2098,50,NULL,'2026-10-15 10:15:40.563957');
INSERT INTO "document_views" VALUES(2099,50,NULL,'2026-10-14 13:40:40.563957');
INSERT INTO "document_views" VALUES(2100,50,NULL,'2026-10-30 01:46:40.563957');
INSERT INTO "document_views" VALUES(2101,50,NULL,'2026-10-29 11:54:40.563957');
INSERT INTO "document_views" VALUES(2102,50,NULL,'2026-10-16 02:13:40.563957');
INSERT INTO "document_views" VALUES(2103,50,NULL,'2026-10-12 14:42:40.563957');
INSERT INTO "document_views" VALUES(2104,50,NULL,'2026-10-04 05:50:40.563957');
INSERT INTO "document_views" VALUES(2105,50,NULL,'2026-10-28 14:34:40.563957');
INSERT INTO "document_views" VALUES(2106,50,NULL,'2026-10-28 22:11:40.563957');
INSERT INTO "document_views" VALUES(2107,50,NULL,'2026-10-25 05:45:40.563957');
INSERT INTO "document_views" VALUES(2108,50,NULL,'2026-10-15 13:32:40.563957');
INSERT INTO "document_views" VALUES(2109,50,NULL,'2026-10-05 18:53:40.563957');
INSERT INTO "document_views" VALUES(2110,50,NULL,'2026-10-24 15:41:40.563957');
INSERT INTO "document_views" VALUES(2111,50,NULL,'2026-10-07 05:51:40.563957');
INSERT INTO "document_views" VALUES(2112,50,NULL,'2026-10-01 20:09:40.563957');
INSERT INTO "document_views" VALUES(2113,50,NULL,'2026-10-30 13:25:40.563957');
INSERT INTO "document_views" VALUES(2114,50,NULL,'2026-10-16 21:52:40.563957');
INSERT INTO "document_views" VALUES(2115,50,NULL,'2026-10-08 22:13:40.563957');
INSERT INTO "document_views" VALUES(2116,50,NULL,'2026-10-18 11:45:40.563957');
INSERT INTO "document_views" VALUES(2117,50,NULL,'2026-10-29 08:54:40.563957');
INSERT INTO "document_views" VALUES(2118,50,NULL,'2026-10-24 11:09:40.563957');
INSERT INTO "document_views" VALUES(2119,50,NULL,'2026-10-16 04:33:40.563957');
INSERT INTO "document_views" VALUES(2120,50,NULL,'2026-10-20 18:22:40.563957');
INSERT INTO "document_views" VALUES(2121,50,NULL,'2026-10-02 23:36:40.563957');
INSERT INTO "document_views" VALUES(2122,50,NULL,'2026-10-20 19:10:40.563957');
INSERT INTO "document_views" VALUES(2123,50,NULL,'2026-10-09 19:26:40.563957');
INSERT INTO "document_views" VALUES(2124,50,NULL,'2026-10-21 14:45:40.563957');
INSERT INTO "document_views" VALUES(2125,50,NULL,'2026-10-07 06:59:40.563957');
INSERT INTO "document_views" VALUES(2126,50,NULL,'2026-10-22 02:28:40.563957');
INSERT INTO "document_views" VALUES(2127,50,NULL,'2026-10-22 23:21:40.563957');
INSERT INTO "document_views" VALUES(2128,50,NULL,'2026-10-30 09:15:40.563957');
INSERT INTO "document_views" VALUES(2129,50,NULL,'2026-10-28 02:05:40.563957');
INSERT INTO "document_views" VALUES(2130,50,NULL,'2026-10-28 18:51:40.563957');
INSERT INTO "document_views" VALUES(2131,50,NULL,'2026-10-18 03:10:40.563957');
INSERT INTO "document_views" VALUES(2132,50,NULL,'2026-10-15 17:03:40.563957');
INSERT INTO "document_views" VALUES(2133,50,NULL,'2026-10-10 03:20:40.563957');
INSERT INTO "document_views" VALUES(2134,50,NULL,'2026-10-21 14:52:40.563957');
INSERT INTO "document_views" VALUES(2135,50,NULL,'2026-10-21 11:03:40.563957');
INSERT INTO "document_views" VALUES(2136,50,NULL,'2026-10-29 17:11:40.563957');
INSERT INTO "document_views" VALUES(2137,50,NULL,'2026-10-31 05:44:40.563957');
INSERT INTO "document_views" VALUES(2138,50,NULL,'2026-10-29 10:59:40.563957');
INSERT INTO "document_views" VALUES(2139,50,NULL,'2026-10-29 09:43:40.563957');
INSERT INTO "document_views" VALUES(2140,50,NULL,'2026-10-20 11:40:40.563957');
INSERT INTO "document_views" VALUES(2141,50,NULL,'2026-10-30 01:32:40.563957');
INSERT INTO "document_views" VALUES(2142,50,NULL,'2026-10-28 01:04:40.563957');
INSERT INTO "document_views" VALUES(2143,50,NULL,'2026-10-20 17:22:40.563957');
INSERT INTO "document_views" VALUES(2144,50,NULL,'2026-10-17 11:58:40.563957');
INSERT INTO "document_views" VALUES(2145,50,NULL,'2026-10-16 08:37:40.563957');
INSERT INTO "document_views" VALUES(2146,50,NULL,'2026-10-10 04:17:40.563957');
INSERT INTO "document_views" VALUES(2147,50,NULL,'2026-10-28 10:30:40.563957');
INSERT INTO "document_views" VALUES(2148,50,NULL,'2026-10-01 14:46:40.563957');
INSERT INTO "document_views" VALUES(2149,50,NULL,'2026-10-29 17:11:40.563957');
INSERT INTO "document_views" VALUES(2150,50,NULL,'2026-10-17 11:19:40.563957');
INSERT INTO "document_views" VALUES(2151,50,NULL,'2026-10-10 01:00:40.563957');
INSERT INTO "document_views" VALUES(2152,50,NULL,'2026-10-16 13:46:40.563957');
INSERT INTO "document_views" VALUES(2153,50,NULL,'2026-10-27 07:48:40.563957');
INSERT INTO "document_views" VALUES(2154,50,NULL,'2026-10-25 15:44:40.563957');
INSERT INTO "document_views" VALUES(2155,50,NULL,'2026-10-18 04:52:40.563957');
INSERT INTO "document_views" VALUES(2156,50,NULL,'2026-10-28 18:03:40.563957');
INSERT INTO "document_views" VALUES(2157,50,NULL,'2026-10-30 06:39:40.563957');
INSERT INTO "document_views" VALUES(2158,50,NULL,'2026-10-28 14:00:40.563957');
INSERT INTO "document_views" VALUES(2159,51,NULL,'2026-10-30 03:55:40.563957');
INSERT INTO "document_views" VALUES(2160,51,NULL,'2026-10-29 10:13:40.563957');
INSERT INTO "document_views" VALUES(2161,51,NULL,'2026-10-17 13:04:40.563957');
INSERT INTO "document_views" VALUES(2162,51,NULL,'2026-10-21 03:12:40.563957');
INSERT INTO "document_views" VALUES(2163,51,NULL,'2026-10-30 08:42:40.563957');
INSERT INTO "document_views" VALUES(2164,51,NULL,'2026-10-29 10:37:40.563957');
INSERT INTO "document_views" VALUES(2165,51,NULL,'2026-10-20 07:10:40.563957');
INSERT INTO "document_views" VALUES(2166,51,NULL,'2026-10-05 08:03:40.563957');
INSERT INTO "document_views" VALUES(2167,51,NULL,'2026-10-15 13:23:40.563957');
INSERT INTO "document_views" VALUES(2168,51,NULL,'2026-10-24 05:44:40.563957');
INSERT INTO "document_views" VALUES(2169,51,NULL,'2026-10-14 16:34:40.563957');
INSERT INTO "document_views" VALUES(2170,51,NULL,'2026-10-28 14:45:40.563957');
INSERT INTO "document_views" VALUES(2171,51,NULL,'2026-10-10 18:12:40.563957');
INSERT INTO "document_views" VALUES(2172,51,NULL,'2026-10-25 07:26:40.563957');
INSERT INTO "document_views" VALUES(2173,51,NULL,'2026-10-18 16:41:40.563957');
INSERT INTO "document_views" VALUES(2174,51,NULL,'2026-10-29 14:55:40.563957');
INSERT INTO "document_views" VALUES(2175,51,NULL,'2026-10-12 04:21:40.563957');
INSERT INTO "document_views" VALUES(2176,51,NULL,'2026-10-27 12:39:40.563957');
INSERT INTO "document_views" VALUES(2177,51,NULL,'2026-10-24 00:45:40.563957');
INSERT INTO "document_views" VALUES(2178,51,NULL,'2026-10-31 06:58:40.563957');
INSERT INTO "document_views" VALUES(2179,51,NULL,'2026-10-19 03:11:40.563957');
INSERT INTO "document_views" VALUES(2180,51,NULL,'2026-10-20 18:24:40.563957');
INSERT INTO "document_views" VALUES(2181,51,NULL,'2026-10-15 07:44:40.563957');
INSERT INTO "document_views" VALUES(2182,51,NULL,'2026-10-09 17:15:40.563957');
INSERT INTO "document_views" VALUES(2183,51,NULL,'2026-10-26 01:56:40.563957');
INSERT INTO "document_views" VALUES(2184,51,NULL,'2026-10-23 11:14:40.563957');
INSERT INTO "document_views" VALUES(2185,51,NULL,'2026-10-27 12:55:40.563957');
INSERT INTO "document_views" VALUES(2186,51,NULL,'2026-10-23 18:44:40.563957');
INSERT INTO "document_views" VALUES(2187,51,NULL,'2026-10-17 07:59:40.563957');
INSERT INTO "document_views" VALUES(2188,51,NULL,'2026-10-25 00:15:40.563957');
INSERT INTO "document_views" VALUES(2189,51,NULL,'2026-10-23 12:11:40.563957');
INSERT INTO "document_views" VALUES(2190,51,NULL,'2026-10-21 18:34:40.563957');
INSERT INTO "document_views" VALUES(2191,52,NULL,'2026-10-21 20:44:40.563957');
INSERT INTO "document_views" VALUES(2192,52,NULL,'2026-10-18 17:37:40.563957');
INSERT INTO "document_views" VALUES(2193,52,NULL,'2026-10-12 08:42:40.563957');
INSERT INTO "document_views" VALUES(2194,52,NULL,'2026-10-30 23:22:40.563957');
INSERT INTO "document_views" VALUES(2195,52,NULL,'2026-10-22 07:20:40.563957');
INSERT INTO "document_views" VALUES(2196,52,NULL,'2026-10-04 03:47:40.563957');
INSERT INTO "document_views" VALUES(2197,52,NULL,'2026-10-28 17:32:40.563957');
INSERT INTO "document_views" VALUES(2198,52,NULL,'2026-10-10 12:25:40.563957');
INSERT INTO "document_views" VALUES(2199,52,NULL,'2026-10-17 07:51:40.563957');
INSERT INTO "document_views" VALUES(2200,52,NULL,'2026-10-14 01:43:40.563957');
INSERT INTO "document_views" VALUES(2201,52,NULL,'2026-10-24 09:30:40.563957');
INSERT INTO "document_views" VALUES(2202,52,NULL,'2026-10-31 04:06:40.563957');
INSERT INTO "document_views" VALUES(2203,52,NULL,'2026-10-09 15:07:40.563957');
INSERT INTO "document_views" VALUES(2204,52,NULL,'2026-10-04 16:21:40.563957');
INSERT INTO "document_views" VALUES(2205,52,NULL,'2026-10-30 22:14:40.563957');
INSERT INTO "document_views" VALUES(2206,52,NULL,'2026-10-29 04:29:40.563957');
INSERT INTO "document_views" VALUES(2207,52,NULL,'2026-10-17 18:05:40.563957');
INSERT INTO "document_views" VALUES(2208,52,NULL,'2026-10-04 17:32:40.563957');
INSERT INTO "document_views" VALUES(2209,52,NULL,'2026-10-17 13:25:40.563957');
INSERT INTO "document_views" VALUES(2210,52,NULL,'2026-10-26 10:49:40.563957');
INSERT INTO "document_views" VALUES(2211,52,NULL,'2026-10-31 01:14:40.563957');
INSERT INTO "document_views" VALUES(2212,52,NULL,'2026-10-16 16:13:40.563957');
INSERT INTO "document_views" VALUES(2213,52,NULL,'2026-10-30 08:47:40.563957');
INSERT INTO "document_views" VALUES(2214,52,NULL,'2026-10-04 13:31:40.563957');
INSERT INTO "document_views" VALUES(2215,52,NULL,'2026-10-27 06:04:40.563957');
INSERT INTO "document_views" VALUES(2216,52,NULL,'2026-10-10 13:47:40.563957');
INSERT INTO "document_views" VALUES(2217,52,NULL,'2026-10-20 23:18:40.563957');
INSERT INTO "document_views" VALUES(2218,52,NULL,'2026-10-17 08:12:40.563957');
INSERT INTO "document_views" VALUES(2219,52,NULL,'2026-10-30 23:03:40.563957');
INSERT INTO "document_views" VALUES(2220,52,NULL,'2026-10-16 01:50:40.563957');
INSERT INTO "document_views" VALUES(2221,52,NULL,'2026-10-30 21:47:40.563957');
INSERT INTO "document_views" VALUES(2222,52,NULL,'2026-10-10 19:09:40.563957');
INSERT INTO "document_views" VALUES(2223,52,NULL,'2026-10-15 17:22:40.563957');
INSERT INTO "document_views" VALUES(2224,52,NULL,'2026-10-18 13:32:40.563957');
INSERT INTO "document_views" VALUES(2225,52,NULL,'2026-10-31 04:52:40.563957');
INSERT INTO "document_views" VALUES(2226,52,NULL,'2026-10-04 12:27:40.563957');
INSERT INTO "document_views" VALUES(2227,52,NULL,'2026-10-26 12:07:40.563957');
INSERT INTO "document_views" VALUES(2228,52,NULL,'2026-10-04 19:20:40.563957');
INSERT INTO "document_views" VALUES(2229,52,NULL,'2026-10-25 21:46:40.563957');
INSERT INTO "document_views" VALUES(2230,52,NULL,'2026-10-29 00:34:40.563957');
INSERT INTO "document_views" VALUES(2231,52,NULL,'2026-10-22 17:25:40.563957');
INSERT INTO "document_views" VALUES(2232,52,NULL,'2026-10-18 22:18:40.563957');
INSERT INTO "document_views" VALUES(2233,52,NULL,'2026-10-29 13:56:40.563957');
INSERT INTO "document_views" VALUES(2234,52,NULL,'2026-10-31 04:44:40.563957');
INSERT INTO "document_views" VALUES(2235,52,NULL,'2026-10-21 19:36:40.563957');
INSERT INTO "document_views" VALUES(2236,52,NULL,'2026-10-03 13:41:40.563957');
INSERT INTO "document_views" VALUES(2237,52,NULL,'2026-10-03 12:51:40.563957');
INSERT INTO "document_views" VALUES(2238,52,NULL,'2026-10-09 11:35:40.563957');
INSERT INTO "document_views" VALUES(2239,52,NULL,'2026-10-27 16:06:40.563957');
INSERT INTO "document_views" VALUES(2240,52,NULL,'2026-10-03 11:59:40.563957');
INSERT INTO "document_views" VALUES(2241,52,NULL,'2026-10-21 22:54:40.563957');
INSERT INTO "document_views" VALUES(2242,53,NULL,'2026-10-06 15:33:40.563957');
INSERT INTO "document_views" VALUES(2243,53,NULL,'2026-10-14 11:11:40.563957');
INSERT INTO "document_views" VALUES(2244,53,NULL,'2026-10-07 14:45:40.563957');
INSERT INTO "document_views" VALUES(2245,53,NULL,'2026-10-31 04:54:40.563957');
INSERT INTO "document_views" VALUES(2246,53,NULL,'2026-10-24 23:41:40.563957');
INSERT INTO "document_views" VALUES(2247,53,NULL,'2026-10-14 23:22:40.563957');
INSERT INTO "document_views" VALUES(2248,53,NULL,'2026-10-10 17:08:40.563957');
INSERT INTO "document_views" VALUES(2249,53,NULL,'2026-10-06 13:35:40.563957');
INSERT INTO "document_views" VALUES(2250,53,NULL,'2026-10-19 07:17:40.563957');
INSERT INTO "document_views" VALUES(2251,53,NULL,'2026-10-08 22:44:40.563957');
INSERT INTO "document_views" VALUES(2252,53,NULL,'2026-10-26 17:35:40.563957');
INSERT INTO "document_views" VALUES(2253,53,NULL,'2026-10-15 19:32:40.563957');
INSERT INTO "document_views" VALUES(2254,53,NULL,'2026-10-31 01:07:40.563957');
INSERT INTO "document_views" VALUES(2255,53,NULL,'2026-10-21 19:08:40.563957');
INSERT INTO "document_views" VALUES(2256,53,NULL,'2026-10-28 11:38:40.563957');
INSERT INTO "document_views" VALUES(2257,53,NULL,'2026-10-27 07:53:40.563957');
INSERT INTO "document_views" VALUES(2258,53,NULL,'2026-10-07 00:43:40.563957');
INSERT INTO "document_views" VALUES(2259,53,NULL,'2026-10-22 00:24:40.563957');
INSERT INTO "document_views" VALUES(2260,53,NULL,'2026-10-28 22:57:40.563957');
INSERT INTO "document_views" VALUES(2261,53,NULL,'2026-10-07 00:09:40.563957');
INSERT INTO "document_views" VALUES(2262,53,NULL,'2026-10-28 22:41:40.563957');
INSERT INTO "document_views" VALUES(2263,53,NULL,'2026-10-08 19:03:40.563957');
INSERT INTO "document_views" VALUES(2264,53,NULL,'2026-10-30 03:34:40.563957');
INSERT INTO "document_views" VALUES(2265,53,NULL,'2026-10-30 04:32:40.563957');
INSERT INTO "document_views" VALUES(2266,53,NULL,'2026-10-14 08:34:40.563957');
INSERT INTO "document_views" VALUES(2267,53,NULL,'2026-10-22 06:59:40.563957');
INSERT INTO "document_views" VALUES(2268,53,NULL,'2026-10-11 12:44:40.563957');
INSERT INTO "document_views" VALUES(2269,53,NULL,'2026-10-06 14:45:40.563957');
INSERT INTO "document_views" VALUES(2270,53,NULL,'2026-10-24 20:27:40.563957');
INSERT INTO "document_views" VALUES(2271,53,NULL,'2026-10-21 11:36:40.563957');
INSERT INTO "document_views" VALUES(2272,53,NULL,'2026-10-07 14:27:40.563957');
INSERT INTO "document_views" VALUES(2273,53,NULL,'2026-10-29 13:46:40.563957');
INSERT INTO "document_views" VALUES(2274,53,NULL,'2026-10-27 23:38:40.563957');
INSERT INTO "document_views" VALUES(2275,53,NULL,'2026-10-13 02:50:40.563957');
INSERT INTO "document_views" VALUES(2276,53,NULL,'2026-10-30 16:46:40.563957');
INSERT INTO "document_views" VALUES(2277,53,NULL,'2026-10-21 12:45:40.563957');
INSERT INTO "document_views" VALUES(2278,53,NULL,'2026-10-30 19:21:40.563957');
INSERT INTO "document_views" VALUES(2279,53,NULL,'2026-10-24 07:47:40.563957');
INSERT INTO "document_views" VALUES(2280,53,NULL,'2026-10-11 15:36:40.563957');
INSERT INTO "document_views" VALUES(2281,53,NULL,'2026-10-06 07:22:40.563957');
INSERT INTO "document_views" VALUES(2282,53,NULL,'2026-10-20 20:26:40.563957');
INSERT INTO "document_views" VALUES(2283,53,NULL,'2026-10-15 06:48:40.563957');
INSERT INTO "document_views" VALUES(2284,53,NULL,'2026-10-15 18:15:40.563957');
INSERT INTO "document_views" VALUES(2285,53,NULL,'2026-10-18 20:06:40.563957');
INSERT INTO "document_views" VALUES(2286,53,NULL,'2026-10-25 22:21:40.563957');
INSERT INTO "document_views" VALUES(2287,53,NULL,'2026-10-28 22:14:40.563957');
INSERT INTO "document_views" VALUES(2288,53,NULL,'2026-10-27 15:07:40.563957');
INSERT INTO "document_views" VALUES(2289,53,NULL,'2026-10-06 19:30:40.563957');
INSERT INTO "document_views" VALUES(2290,53,NULL,'2026-10-24 14:11:40.563957');
INSERT INTO "document_views" VALUES(2291,53,NULL,'2026-10-23 16:54:40.563957');
INSERT INTO "document_views" VALUES(2292,53,NULL,'2026-10-14 18:30:40.563957');
INSERT INTO "document_views" VALUES(2293,53,NULL,'2026-10-25 17:32:40.563957');
INSERT INTO "document_views" VALUES(2294,53,NULL,'2026-10-28 01:04:40.563957');
INSERT INTO "document_views" VALUES(2295,53,NULL,'2026-10-18 11:33:40.563957');
INSERT INTO "document_views" VALUES(2296,53,NULL,'2026-10-15 03:48:40.563957');
INSERT INTO "document_views" VALUES(2297,53,NULL,'2026-10-13 23:10:40.563957');
INSERT INTO "document_views" VALUES(2298,53,NULL,'2026-10-19 18:12:40.563957');
INSERT INTO "document_views" VALUES(2299,53,NULL,'2026-10-29 02:06:40.563957');
INSERT INTO "document_views" VALUES(2300,53,NULL,'2026-10-22 06:53:40.563957');
INSERT INTO "document_views" VALUES(2301,53,NULL,'2026-10-29 14:09:40.563957');
INSERT INTO "document_views" VALUES(2302,53,NULL,'2026-10-29 09:41:40.563957');
INSERT INTO "document_views" VALUES(2303,53,NULL,'2026-10-20 20:26:40.563957');
INSERT INTO "document_views" VALUES(2304,53,NULL,'2026-10-10 20:58:40.563957');
INSERT INTO "document_views" VALUES(2305,53,NULL,'2026-10-27 11:50:40.563957');
INSERT INTO "document_views" VALUES(2306,53,NULL,'2026-10-31 03:50:40.563957');
INSERT INTO "document_views" VALUES(2307,53,NULL,'2026-10-15 05:10:40.563957');
INSERT INTO "document_views" VALUES(2308,53,NULL,'2026-10-28 22:32:40.563957');
INSERT INTO "document_views" VALUES(2309,53,NULL,'2026-10-21 09:43:40.563957');
INSERT INTO "document_views" VALUES(2310,53,NULL,'2026-10-30 19:47:40.563957');
INSERT INTO "document_views" VALUES(2311,53,NULL,'2026-10-27 18:55:40.563957');
INSERT INTO "document_views" VALUES(2312,53,NULL,'2026-10-19 22:25:40.563957');
INSERT INTO "document_views" VALUES(2313,53,NULL,'2026-10-25 17:09:40.563957');
INSERT INTO "document_views" VALUES(2314,53,NULL,'2026-10-29 08:01:40.563957');
INSERT INTO "document_views" VALUES(2315,53,NULL,'2026-10-07 00:25:40.563957');
INSERT INTO "document_views" VALUES(2316,53,NULL,'2026-10-18 09:02:40.563957');
INSERT INTO "document_views" VALUES(2317,53,NULL,'2026-10-16 01:15:40.563957');
INSERT INTO "document_views" VALUES(2318,53,NULL,'2026-10-06 21:30:40.563957');
INSERT INTO "document_views" VALUES(2319,53,NULL,'2026-10-25 08:14:40.563957');
INSERT INTO "document_views" VALUES(2320,53,NULL,'2026-10-20 15:57:40.563957');
INSERT INTO "document_views" VALUES(2321,53,NULL,'2026-10-06 18:12:40.563957');
INSERT INTO "document_views" VALUES(2322,53,NULL,'2026-10-17 15:23:40.563957');
INSERT INTO "document_views" VALUES(2323,53,NULL,'2026-10-17 02:16:40.563957');
INSERT INTO "document_views" VALUES(2324,53,NULL,'2026-10-07 09:21:40.563957');
INSERT INTO "document_views" VALUES(2325,53,NULL,'2026-10-09 19:42:40.563957');
INSERT INTO "document_views" VALUES(2326,53,NULL,'2026-10-23 10:18:40.563957');
INSERT INTO "document_views" VALUES(2327,53,NULL,'2026-10-19 04:46:40.563957');
INSERT INTO "document_views" VALUES(2328,53,NULL,'2026-10-30 19:29:40.563957');
INSERT INTO "document_views" VALUES(2329,53,NULL,'2026-10-28 20:24:40.563957');
INSERT INTO "document_views" VALUES(2330,54,NULL,'2026-10-13 10:33:40.563957');
INSERT INTO "document_views" VALUES(2331,54,NULL,'2026-10-16 21:57:40.563957');
INSERT INTO "document_views" VALUES(2332,54,NULL,'2026-10-09 18:49:40.563957');
INSERT INTO "document_views" VALUES(2333,54,NULL,'2026-10-12 13:26:40.563957');
INSERT INTO "document_views" VALUES(2334,54,NULL,'2026-10-09 17:05:40.563957');
INSERT INTO "document_views" VALUES(2335,54,NULL,'2026-10-30 06:25:40.563957');
INSERT INTO "document_views" VALUES(2336,54,NULL,'2026-10-29 23:12:40.563957');
INSERT INTO "document_views" VALUES(2337,54,NULL,'2026-10-15 07:17:40.563957');
INSERT INTO "document_views" VALUES(2338,54,NULL,'2026-10-13 00:01:40.563957');
INSERT INTO "document_views" VALUES(2339,54,NULL,'2026-10-30 03:42:40.563957');
INSERT INTO "document_views" VALUES(2340,54,NULL,'2026-10-30 15:03:40.563957');
INSERT INTO "document_views" VALUES(2341,54,NULL,'2026-10-20 06:19:40.563957');
INSERT INTO "document_views" VALUES(2342,54,NULL,'2026-10-11 13:19:40.563957');
INSERT INTO "document_views" VALUES(2343,54,NULL,'2026-10-12 04:22:40.563957');
INSERT INTO "document_views" VALUES(2344,54,NULL,'2026-10-30 10:07:40.563957');
INSERT INTO "document_views" VALUES(2345,54,NULL,'2026-10-29 08:51:40.563957');
INSERT INTO "document_views" VALUES(2346,54,NULL,'2026-10-09 17:54:40.563957');
INSERT INTO "document_views" VALUES(2347,54,NULL,'2026-10-26 22:46:40.563957');
INSERT INTO "document_views" VALUES(2348,54,NULL,'2026-10-12 16:05:40.563957');
INSERT INTO "document_views" VALUES(2349,54,NULL,'2026-10-17 02:44:40.563957');
INSERT INTO "document_views" VALUES(2350,54,NULL,'2026-10-21 01:23:40.563957');
INSERT INTO "document_views" VALUES(2351,54,NULL,'2026-10-30 08:34:40.563957');
INSERT INTO "document_views" VALUES(2352,54,NULL,'2026-10-25 20:06:40.563957');
INSERT INTO "document_views" VALUES(2353,54,NULL,'2026-10-09 15:16:40.563957');
INSERT INTO "document_views" VALUES(2354,54,NULL,'2026-10-09 12:45:40.563957');
INSERT INTO "document_views" VALUES(2355,54,NULL,'2026-10-09 12:29:40.563957');
INSERT INTO "document_views" VALUES(2356,54,NULL,'2026-10-22 07:24:40.563957');
INSERT INTO "document_views" VALUES(2357,54,NULL,'2026-10-19 11:02:40.563957');
INSERT INTO "document_views" VALUES(2358,54,NULL,'2026-10-17 09:40:40.563957');
INSERT INTO "document_views" VALUES(2359,54,NULL,'2026-10-12 11:57:40.563957');
INSERT INTO "document_views" VALUES(2360,54,NULL,'2026-10-23 09:22:40.563957');
INSERT INTO "document_views" VALUES(2361,54,NULL,'2026-10-16 20:38:40.563957');
INSERT INTO "document_views" VALUES(2362,54,NULL,'2026-10-09 14:46:40.563957');
INSERT INTO "document_views" VALUES(2363,54,NULL,'2026-10-20 04:09:40.563957');
INSERT INTO "document_views" VALUES(2364,54,NULL,'2026-10-22 18:43:40.563957');
INSERT INTO "document_views" VALUES(2365,54,NULL,'2026-10-24 01:54:40.563957');
INSERT INTO "document_views" VALUES(2366,54,NULL,'2026-10-27 07:12:40.563957');
INSERT INTO "document_views" VALUES(2367,54,NULL,'2026-10-21 02:33:40.563957');
INSERT INTO "document_views" VALUES(2368,54,NULL,'2026-10-25 15:12:40.563957');
INSERT INTO "document_views" VALUES(2369,54,NULL,'2026-10-19 07:44:40.563957');
INSERT INTO "document_views" VALUES(2370,54,NULL,'2026-10-09 14:55:40.563957');
INSERT INTO "document_views" VALUES(2371,54,NULL,'2026-10-26 16:31:40.563957');
INSERT INTO "document_views" VALUES(2372,54,NULL,'2026-10-10 10:50:40.563957');
INSERT INTO "document_views" VALUES(2373,54,NULL,'2026-10-29 06:58:40.563957');
INSERT INTO "document_views" VALUES(2374,54,NULL,'2026-10-20 00:46:40.563957');
INSERT INTO "document_views" VALUES(2375,54,NULL,'2026-10-23 12:04:40.563957');
INSERT INTO "document_views" VALUES(2376,54,NULL,'2026-10-23 22:41:40.563957');
INSERT INTO "document_views" VALUES(2377,54,NULL,'2026-10-29 09:10:40.563957');
INSERT INTO "document_views" VALUES(2378,54,NULL,'2026-10-24 18:18:40.563957');
INSERT INTO "document_views" VALUES(2379,54,NULL,'2026-10-29 04:30:40.563957');
INSERT INTO "document_views" VALUES(2380,54,NULL,'2026-10-23 23:02:40.563957');
INSERT INTO "document_views" VALUES(2381,54,NULL,'2026-10-20 10:17:40.563957');
INSERT INTO "document_views" VALUES(2382,54,NULL,'2026-10-09 07:50:40.563957');
INSERT INTO "document_views" VALUES(2383,54,NULL,'2026-10-27 09:04:40.563957');
INSERT INTO "document_views" VALUES(2384,54,NULL,'2026-10-12 22:02:40.563957');
INSERT INTO "document_views" VALUES(2385,54,NULL,'2026-10-24 04:52:40.563957');
INSERT INTO "document_views" VALUES(2386,54,NULL,'2026-10-29 21:19:40.563957');
INSERT INTO "document_views" VALUES(2387,54,NULL,'2026-10-30 15:40:40.563957');
INSERT INTO "document_views" VALUES(2388,54,NULL,'2026-10-17 21:55:40.563957');
INSERT INTO "document_views" VALUES(2389,54,NULL,'2026-10-14 14:25:40.563957');
INSERT INTO "document_views" VALUES(2390,54,NULL,'2026-10-29 06:33:40.563957');
INSERT INTO "document_views" VALUES(2391,54,NULL,'2026-10-29 12:57:40.563957');
INSERT INTO "document_views" VALUES(2392,54,NULL,'2026-10-31 03:43:40.563957');
INSERT INTO "document_views" VALUES(2393,54,NULL,'2026-10-28 02:56:40.563957');
INSERT INTO "document_views" VALUES(2394,54,NULL,'2026-10-14 06:56:40.563957');
INSERT INTO "document_views" VALUES(2395,54,NULL,'2026-10-29 02:04:40.563957');
INSERT INTO "document_views" VALUES(2396,54,NULL,'2026-10-30 23:48:40.563957');
INSERT INTO "document_views" VALUES(2397,55,NULL,'2026-10-26 14:12:40.563957');
INSERT INTO "document_views" VALUES(2398,55,NULL,'2026-10-12 15:23:40.563957');
INSERT INTO "document_views" VALUES(2399,55,NULL,'2026-10-15 06:08:40.563957');
INSERT INTO "document_views" VALUES(2400,55,NULL,'2026-10-26 02:13:40.563957');
INSERT INTO "document_views" VALUES(2401,55,NULL,'2026-10-30 17:49:40.563957');
INSERT INTO "document_views" VALUES(2402,55,NULL,'2026-10-30 15:10:40.563957');
INSERT INTO "document_views" VALUES(2403,55,NULL,'2026-10-29 22:40:40.563957');
INSERT INTO "document_views" VALUES(2404,55,NULL,'2026-10-13 06:47:40.563957');
INSERT INTO "document_views" VALUES(2405,55,NULL,'2026-10-29 22:43:40.563957');
INSERT INTO "document_views" VALUES(2406,55,NULL,'2026-10-24 16:05:40.563957');
INSERT INTO "document_views" VALUES(2407,55,NULL,'2026-10-28 06:04:40.563957');
INSERT INTO "document_views" VALUES(2408,55,NULL,'2026-10-29 04:00:40.563957');
INSERT INTO "document_views" VALUES(2409,55,NULL,'2026-10-21 00:06:40.563957');
INSERT INTO "document_views" VALUES(2410,55,NULL,'2026-10-21 07:57:40.563957');
INSERT INTO "document_views" VALUES(2411,55,NULL,'2026-10-12 20:11:40.563957');
INSERT INTO "document_views" VALUES(2412,55,NULL,'2026-10-30 05:46:40.563957');
INSERT INTO "document_views" VALUES(2413,55,NULL,'2026-10-12 12:27:40.563957');
INSERT INTO "document_views" VALUES(2414,55,NULL,'2026-10-20 22:34:40.563957');
INSERT INTO "document_views" VALUES(2415,55,NULL,'2026-10-21 21:01:40.563957');
INSERT INTO "document_views" VALUES(2416,55,NULL,'2026-10-29 05:26:40.563957');
INSERT INTO "document_views" VALUES(2417,55,NULL,'2026-10-12 23:46:40.563957');
INSERT INTO "document_views" VALUES(2418,55,NULL,'2026-10-12 23:09:40.563957');
INSERT INTO "document_views" VALUES(2419,55,NULL,'2026-10-16 20:08:40.563957');
INSERT INTO "document_views" VALUES(2420,55,NULL,'2026-10-30 21:47:40.563957');
INSERT INTO "document_views" VALUES(2421,56,NULL,'2026-10-24 22:55:40.563957');
INSERT INTO "document_views" VALUES(2422,56,NULL,'2026-10-31 05:46:40.563957');
INSERT INTO "document_views" VALUES(2423,56,NULL,'2026-10-18 07:38:40.563957');
INSERT INTO "document_views" VALUES(2424,56,NULL,'2026-10-21 10:51:40.563957');
INSERT INTO "document_views" VALUES(2425,56,NULL,'2026-10-30 04:09:40.563957');
INSERT INTO "document_views" VALUES(2426,56,NULL,'2026-10-27 14:09:40.563957');
INSERT INTO "document_views" VALUES(2427,56,NULL,'2026-10-30 10:06:40.563957');
INSERT INTO "document_views" VALUES(2428,56,NULL,'2026-10-25 09:52:40.563957');
INSERT INTO "document_views" VALUES(2429,56,NULL,'2026-10-30 19:04:40.563957');
INSERT INTO "document_views" VALUES(2430,56,NULL,'2026-10-16 07:16:40.563957');
INSERT INTO "document_views" VALUES(2431,56,NULL,'2026-10-20 03:33:40.563957');
INSERT INTO "document_views" VALUES(2432,56,NULL,'2026-10-29 23:16:40.563957');
INSERT INTO "document_views" VALUES(2433,56,NULL,'2026-10-26 12:09:40.563957');
INSERT INTO "document_views" VALUES(2434,56,NULL,'2026-10-15 19:21:40.563957');
INSERT INTO "document_views" VALUES(2435,56,NULL,'2026-10-15 16:14:40.563957');
INSERT INTO "document_views" VALUES(2436,56,NULL,'2026-10-16 06:29:40.563957');
INSERT INTO "document_views" VALUES(2437,56,NULL,'2026-10-15 18:59:40.563957');
INSERT INTO "document_views" VALUES(2438,56,NULL,'2026-10-15 22:39:40.563957');
INSERT INTO "document_views" VALUES(2439,56,NULL,'2026-10-15 14:39:40.563957');
INSERT INTO "document_views" VALUES(2440,56,NULL,'2026-10-15 12:08:40.563957');
INSERT INTO "document_views" VALUES(2441,56,NULL,'2026-10-26 07:25:40.563957');
INSERT INTO "document_views" VALUES(2442,56,NULL,'2026-10-21 11:52:40.563957');
INSERT INTO "document_views" VALUES(2443,56,NULL,'2026-10-28 19:20:40.563957');
INSERT INTO "document_views" VALUES(2444,56,NULL,'2026-10-26 15:13:40.563957');
INSERT INTO "document_views" VALUES(2445,56,NULL,'2026-10-27 10:46:40.563957');
INSERT INTO "document_views" VALUES(2446,56,NULL,'2026-10-15 12:17:40.563957');
INSERT INTO "document_views" VALUES(2447,56,NULL,'2026-10-29 13:05:40.563957');
INSERT INTO "document_views" VALUES(2448,56,NULL,'2026-10-29 21:07:40.563957');
INSERT INTO "document_views" VALUES(2449,56,NULL,'2026-10-15 12:43:40.563957');
INSERT INTO "document_views" VALUES(2450,56,NULL,'2026-10-25 07:11:40.563957');
INSERT INTO "document_views" VALUES(2451,56,NULL,'2026-10-15 13:56:40.563957');
INSERT INTO "document_views" VALUES(2452,56,NULL,'2026-10-25 00:53:40.563957');
INSERT INTO "document_views" VALUES(2453,56,NULL,'2026-10-15 10:03:40.563957');
INSERT INTO "document_views" VALUES(2454,56,NULL,'2026-10-15 10:02:40.563957');
INSERT INTO "document_views" VALUES(2455,56,NULL,'2026-10-28 05:03:40.563957');
INSERT INTO "document_views" VALUES(2456,56,NULL,'2026-10-15 12:49:40.563957');
INSERT INTO "document_views" VALUES(2457,56,NULL,'2026-10-16 00:44:40.563957');
INSERT INTO "document_views" VALUES(2458,56,NULL,'2026-10-20 14:14:40.563957');
INSERT INTO "document_views" VALUES(2459,56,NULL,'2026-10-16 01:57:40.563957');
INSERT INTO "document_views" VALUES(2460,56,NULL,'2026-10-17 20:12:40.563957');
INSERT INTO "document_views" VALUES(2461,56,NULL,'2026-10-23 20:13:40.563957');
INSERT INTO "document_views" VALUES(2462,56,NULL,'2026-10-30 13:21:40.563957');
INSERT INTO "document_views" VALUES(2463,56,NULL,'2026-10-16 05:43:40.563957');
INSERT INTO "document_views" VALUES(2464,56,NULL,'2026-10-16 02:47:40.563957');
INSERT INTO "document_views" VALUES(2465,56,NULL,'2026-10-30 06:08:40.563957');
INSERT INTO "document_views" VALUES(2466,56,NULL,'2026-10-28 14:38:40.563957');
INSERT INTO "document_views" VALUES(2467,56,NULL,'2026-10-29 06:07:40.563957');
INSERT INTO "document_views" VALUES(2468,56,NULL,'2026-10-18 17:57:40.563957');
INSERT INTO "document_views" VALUES(2469,56,NULL,'2026-10-15 13:16:40.563957');
INSERT INTO "document_views" VALUES(2470,56,NULL,'2026-10-16 11:04:40.563957');
INSERT INTO "document_views" VALUES(2471,56,NULL,'2026-10-27 18:42:40.563957');
INSERT INTO "document_views" VALUES(2472,56,NULL,'2026-10-29 04:47:40.563957');
INSERT INTO "document_views" VALUES(2473,56,NULL,'2026-10-31 00:05:40.563957');
INSERT INTO "document_views" VALUES(2474,56,NULL,'2026-10-16 04:29:40.563957');
INSERT INTO "document_views" VALUES(2475,56,NULL,'2026-10-22 09:24:40.563957');
INSERT INTO "document_views" VALUES(2476,57,NULL,'2026-10-19 17:01:40.563957');
INSERT INTO "document_views" VALUES(2477,57,NULL,'2026-10-19 05:13:40.563957');
INSERT INTO "document_views" VALUES(2478,57,NULL,'2026-10-18 22:08:40.563957');
INSERT INTO "document_views" VALUES(2479,57,NULL,'2026-10-21 04:48:40.563957');
INSERT INTO "document_views" VALUES(2480,57,NULL,'2026-10-19 04:33:40.563957');
INSERT INTO "document_views" VALUES(2481,57,NULL,'2026-10-18 13:29:40.563957');
INSERT INTO "document_views" VALUES(2482,57,NULL,'2026-10-30 23:19:40.563957');
INSERT INTO "document_views" VALUES(2483,57,NULL,'2026-10-21 00:44:40.563957');
INSERT INTO "document_views" VALUES(2484,58,NULL,'2026-10-21 11:45:40.563957');
INSERT INTO "document_views" VALUES(2485,58,NULL,'2026-10-22 01:06:40.563957');
INSERT INTO "document_views" VALUES(2486,58,NULL,'2026-10-21 12:09:40.563957');
INSERT INTO "document_views" VALUES(2487,58,NULL,'2026-10-24 03:36:40.563957');
INSERT INTO "document_views" VALUES(2488,58,NULL,'2026-10-21 11:32:40.563957');
INSERT INTO "document_views" VALUES(2489,58,NULL,'2026-10-25 15:33:40.563957');
INSERT INTO "document_views" VALUES(2490,58,NULL,'2026-10-21 16:38:40.563957');
INSERT INTO "document_views" VALUES(2491,58,NULL,'2026-10-22 01:31:40.563957');
INSERT INTO "document_views" VALUES(2492,58,NULL,'2026-10-21 12:26:40.563957');
INSERT INTO "document_views" VALUES(2493,58,NULL,'2026-10-24 19:41:40.563957');
INSERT INTO "document_views" VALUES(2494,58,NULL,'2026-10-21 12:59:40.563957');
INSERT INTO "document_views" VALUES(2495,58,NULL,'2026-10-21 16:05:40.563957');
INSERT INTO "document_views" VALUES(2496,58,NULL,'2026-10-21 20:27:40.563957');
INSERT INTO "document_views" VALUES(2497,59,NULL,'2026-10-24 18:31:40.563957');
INSERT INTO "document_views" VALUES(2498,59,NULL,'2026-10-24 09:36:40.563957');
INSERT INTO "document_views" VALUES(2499,59,NULL,'2026-10-24 20:10:40.563957');
INSERT INTO "document_views" VALUES(2500,59,NULL,'2026-10-24 11:59:40.563957');
INSERT INTO "document_views" VALUES(2501,59,NULL,'2026-10-24 18:24:40.563957');
INSERT INTO "document_views" VALUES(2502,59,NULL,'2026-10-24 22:32:40.563957');
INSERT INTO "document_views" VALUES(2503,59,NULL,'2026-10-25 15:46:40.563957');
INSERT INTO "document_views" VALUES(2504,59,NULL,'2026-10-24 17:39:40.563957');
INSERT INTO "document_views" VALUES(2505,59,NULL,'2026-10-31 06:02:40.563957');
INSERT INTO "document_views" VALUES(2506,59,NULL,'2026-10-24 10:52:40.563957');
INSERT INTO "document_views" VALUES(2507,59,NULL,'2026-10-31 02:36:40.563957');
INSERT INTO "document_views" VALUES(2508,59,NULL,'2026-10-24 20:54:40.563957');
INSERT INTO "document_views" VALUES(2509,59,NULL,'2026-10-30 23:38:40.563957');
INSERT INTO "document_views" VALUES(2510,59,NULL,'2026-10-28 20:28:40.563957');
INSERT INTO "document_views" VALUES(2511,59,NULL,'2026-10-30 07:40:40.563957');
INSERT INTO "document_views" VALUES(2512,59,NULL,'2026-10-24 12:19:40.563957');
INSERT INTO "document_views" VALUES(2513,59,NULL,'2026-10-24 11:44:40.563957');
INSERT INTO "document_views" VALUES(2514,59,NULL,'2026-10-25 01:56:40.563957');
INSERT INTO "document_views" VALUES(2515,59,NULL,'2026-10-30 15:30:40.563957');
INSERT INTO "document_views" VALUES(2516,59,NULL,'2026-10-26 02:29:40.563957');
INSERT INTO "document_views" VALUES(2517,59,NULL,'2026-10-27 11:20:40.563957');
INSERT INTO "document_views" VALUES(2518,59,NULL,'2026-10-27 22:28:40.563957');
INSERT INTO "document_views" VALUES(2519,59,NULL,'2026-10-25 04:04:40.563957');
INSERT INTO "document_views" VALUES(2520,59,NULL,'2026-10-24 11:47:40.563957');
INSERT INTO "document_views" VALUES(2521,59,NULL,'2026-10-25 04:34:40.563957');
INSERT INTO "document_views" VALUES(2522,59,NULL,'2026-10-24 14:44:40.563957');
INSERT INTO "document_views" VALUES(2523,59,NULL,'2026-10-29 07:40:40.563957');
INSERT INTO "document_views" VALUES(2524,59,NULL,'2026-10-25 03:57:40.563957');
INSERT INTO "document_views" VALUES(2525,59,NULL,'2026-10-24 20:57:40.563957');
INSERT INTO "document_views" VALUES(2526,59,NULL,'2026-10-30 11:32:40.563957');
INSERT INTO "document_views" VALUES(2527,59,NULL,'2026-10-25 05:18:40.563957');
INSERT INTO "document_views" VALUES(2528,59,NULL,'2026-10-24 19:48:40.563957');
INSERT INTO "document_views" VALUES(2529,59,NULL,'2026-10-25 16:23:40.563957');
INSERT INTO "document_views" VALUES(2530,59,NULL,'2026-10-25 03:06:40.563957');
INSERT INTO "document_views" VALUES(2531,59,NULL,'2026-10-24 23:28:40.563957');
INSERT INTO "document_views" VALUES(2532,59,NULL,'2026-10-24 10:39:40.563957');
INSERT INTO "document_views" VALUES(2533,59,NULL,'2026-10-24 09:34:40.563957');
INSERT INTO "document_views" VALUES(2534,59,NULL,'2026-10-24 18:09:40.563957');
INSERT INTO "document_views" VALUES(2535,59,NULL,'2026-10-30 13:19:40.563957');
INSERT INTO "document_views" VALUES(2536,59,NULL,'2026-10-30 12:47:40.563957');
INSERT INTO "document_views" VALUES(2537,59,NULL,'2026-10-24 20:03:40.563957');
INSERT INTO "document_views" VALUES(2538,59,NULL,'2026-10-24 23:40:40.563957');
INSERT INTO "document_views" VALUES(2539,59,NULL,'2026-10-29 08:13:40.563957');
INSERT INTO "document_views" VALUES(2540,59,NULL,'2026-10-24 17:48:40.563957');
INSERT INTO "document_views" VALUES(2541,59,NULL,'2026-10-24 10:54:40.563957');
INSERT INTO "document_views" VALUES(2542,59,NULL,'2026-10-25 04:08:40.563957');
INSERT INTO "document_views" VALUES(2543,59,NULL,'2026-10-28 21:19:40.563957');
INSERT INTO "document_views" VALUES(2544,59,NULL,'2026-10-25 02:09:40.563957');
INSERT INTO "document_views" VALUES(2545,59,NULL,'2026-10-30 04:23:40.563957');
INSERT INTO "document_views" VALUES(2546,59,NULL,'2026-10-25 05:32:40.563957');
INSERT INTO "document_views" VALUES(2547,60,NULL,'2026-10-27 17:36:40.563957');
INSERT INTO "document_views" VALUES(2548,60,NULL,'2026-10-27 07:23:40.563957');
INSERT INTO "document_views" VALUES(2549,60,NULL,'2026-10-30 02:36:40.563957');
INSERT INTO "document_views" VALUES(2550,60,NULL,'2026-10-28 00:27:40.563957');
INSERT INTO "document_views" VALUES(2551,60,NULL,'2026-10-27 08:57:40.563957');
INSERT INTO "document_views" VALUES(2552,60,NULL,'2026-10-27 12:03:40.563957');
INSERT INTO "document_views" VALUES(2553,60,NULL,'2026-10-27 13:19:40.563957');
INSERT INTO "document_views" VALUES(2554,60,NULL,'2026-10-28 04:46:40.563957');
INSERT INTO "document_views" VALUES(2555,60,NULL,'2026-10-27 16:32:40.563957');
INSERT INTO "document_views" VALUES(2556,60,NULL,'2026-10-27 11:33:40.563957');
INSERT INTO "document_views" VALUES(2557,60,NULL,'2026-10-30 08:17:40.563957');
INSERT INTO "document_views" VALUES(2558,60,NULL,'2026-10-27 18:44:40.563957');
INSERT INTO "document_views" VALUES(2559,60,NULL,'2026-10-27 20:16:40.563957');
INSERT INTO "document_views" VALUES(2560,60,NULL,'2026-10-27 08:50:40.563957');
INSERT INTO "document_views" VALUES(2561,60,NULL,'2026-10-30 20:48:40.563957');
INSERT INTO "document_views" VALUES(2562,60,NULL,'2026-10-29 19:16:40.563957');
INSERT INTO "document_views" VALUES(2563,60,NULL,'2026-10-27 16:07:40.563957');
INSERT INTO "document_views" VALUES(2564,60,NULL,'2026-10-27 16:10:40.563957');
INSERT INTO "document_views" VALUES(2565,60,NULL,'2026-10-30 23:14:40.563957');
INSERT INTO "document_views" VALUES(2566,60,NULL,'2026-10-28 18:27:40.563957');
INSERT INTO "document_views" VALUES(2567,60,NULL,'2026-10-30 04:17:40.563957');
INSERT INTO "document_views" VALUES(2568,60,NULL,'2026-10-31 05:21:40.563957');
INSERT INTO "document_views" VALUES(2569,60,NULL,'2026-10-27 10:01:40.563957');
INSERT INTO "document_views" VALUES(2570,60,NULL,'2026-10-27 21:23:40.563957');
INSERT INTO "document_views" VALUES(2571,60,NULL,'2026-10-30 07:32:40.563957');
INSERT INTO "document_views" VALUES(2572,60,NULL,'2026-10-27 20:48:40.563957');
INSERT INTO "document_views" VALUES(2573,60,NULL,'2026-10-28 06:26:40.563957');
INSERT INTO "document_views" VALUES(2574,60,NULL,'2026-10-27 12:51:40.563957');
INSERT INTO "document_views" VALUES(2575,60,NULL,'2026-10-28 12:33:40.563957');
INSERT INTO "document_views" VALUES(2576,60,NULL,'2026-10-27 22:23:40.563957');
INSERT INTO "document_views" VALUES(2577,60,NULL,'2026-10-27 09:57:40.563957');
INSERT INTO "document_views" VALUES(2578,60,NULL,'2026-10-28 02:23:40.563957');
INSERT INTO "document_views" VALUES(2579,60,NULL,'2026-10-27 08:24:40.563957');
INSERT INTO "document_views" VALUES(2580,60,NULL,'2026-10-30 11:19:40.563957');
INSERT INTO "document_views" VALUES(2581,60,NULL,'2026-10-27 13:14:40.563957');
INSERT INTO "document_views" VALUES(2582,60,NULL,'2026-10-31 01:24:40.563957');
INSERT INTO "document_views" VALUES(2583,60,NULL,'2026-10-31 00:21:40.563957');
INSERT INTO "document_views" VALUES(2584,60,NULL,'2026-10-27 10:07:40.563957');
INSERT INTO "document_views" VALUES(2585,60,NULL,'2026-10-27 15:20:40.563957');
INSERT INTO "document_views" VALUES(2586,60,NULL,'2026-10-28 06:55:40.563957');
INSERT INTO "document_views" VALUES(2587,60,NULL,'2026-10-30 08:40:40.563957');
INSERT INTO "document_views" VALUES(2588,60,NULL,'2026-10-27 08:41:40.563957');
INSERT INTO "document_views" VALUES(2589,60,NULL,'2026-10-28 03:32:40.563957');
INSERT INTO "document_views" VALUES(2590,60,NULL,'2026-10-30 09:03:40.563957');
INSERT INTO "document_views" VALUES(2591,60,NULL,'2026-10-27 18:13:40.563957');
INSERT INTO "document_views" VALUES(2592,60,NULL,'2026-10-28 03:49:40.563957');
INSERT INTO "document_views" VALUES(2593,60,NULL,'2026-10-27 14:40:40.563957');
INSERT INTO "document_views" VALUES(2594,60,NULL,'2026-10-27 13:04:40.563957');
INSERT INTO "document_views" VALUES(2595,60,NULL,'2026-10-31 00:25:40.563957');
INSERT INTO "document_views" VALUES(2596,60,NULL,'2026-10-27 15:35:40.563957');
INSERT INTO "document_views" VALUES(2597,59,NULL,'2026-10-31 07:13:56.564213');
CREATE TABLE documents (
	id INTEGER NOT NULL, 
	title VARCHAR(255) NOT NULL, 
	slug VARCHAR(280) NOT NULL, 
	summary TEXT NOT NULL, 
	content TEXT NOT NULL, 
	content_text TEXT NOT NULL, 
	category_id INTEGER, 
	author_id INTEGER, 
	cover_image_url VARCHAR(500), 
	status VARCHAR(20) NOT NULL, 
	published_at DATETIME, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	views_count INTEGER NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(category_id) REFERENCES categories (id) ON DELETE SET NULL, 
	FOREIGN KEY(author_id) REFERENCES users (id) ON DELETE SET NULL
);
INSERT INTO "documents" VALUES(1,'Groundwater: the hidden reservoir beneath our feet','groundwater-the-hidden-reservoir-beneath-our-feet','Much of the world''s drinking and irrigation water comes from underground aquifers. They refill slowly, so overuse and pollution can have lasting effects.','<p>Groundwater is water stored in the spaces between grains of sand, gravel and rock below the surface. Layers that hold and transmit enough water to supply wells are called aquifers. Groundwater feeds springs and rivers during dry periods and supplies a large share of the water used for drinking and irrigation worldwide.</p>
<p>Aquifers are recharged when rain and snowmelt soak into the ground. In some places this happens within years; in others, especially deep aquifers in dry regions, the water may be thousands of years old and recharges extremely slowly.</p>
<h2>When extraction outpaces recharge</h2>
<p>Pumping more water than is replenished lowers the water table. Wells must be drilled deeper, rivers and wetlands can dry out, and in some regions the ground itself sinks as sediments compact. Near coasts, over-pumping can draw salty seawater into freshwater aquifers.</p>
<h2>Protecting a shared resource</h2>
<p>Because groundwater moves slowly, pollution from fertilisers, industrial chemicals or leaking tanks can persist for decades. Monitoring water levels, pricing and permitting extraction fairly, using efficient irrigation and allowing rainwater to soak into the ground in cities all help keep aquifers healthy.</p>','Groundwater is water stored in the spaces between grains of sand, gravel and rock below the surface. Layers that hold and transmit enough water to supply wells are called aquifers. Groundwater feeds springs and rivers during dry periods and supplies a large share of the water used for drinking and irrigation worldwide.
Aquifers are recharged when rain and snowmelt soak into the ground. In some places this happens within years; in others, especially deep aquifers in dry regions, the water may be thousands of years old and recharges extremely slowly.
When extraction outpaces recharge
Pumping more water than is replenished lowers the water table. Wells must be drilled deeper, rivers and wetlands can dry out, and in some regions the ground itself sinks as sediments compact. Near coasts, over-pumping can draw salty seawater into freshwater aquifers.
Protecting a shared resource
Because groundwater moves slowly, pollution from fertilisers, industrial chemicals or leaking tanks can persist for decades. Monitoring water levels, pricing and permitting extraction fairly, using efficient irrigation and allowing rainwater to soak into the ground in cities all help keep aquifers healthy.',4,7,'/media/covers/groundwater-the-hidden-reservoir-beneath-our-feet.svg','draft',NULL,'2026-04-30 11:12:40.563957','2026-05-03 11:12:40.563957',0);
INSERT INTO "documents" VALUES(2,'Understanding blood pressure numbers','understanding-blood-pressure-numbers','Blood pressure readings have two numbers, and both matter. What they mean, why high blood pressure is called silent, and how to measure it correctly at home.','<p>A blood pressure reading such as 118/76 has two parts. The first, systolic pressure, is the pressure in your arteries when the heart beats. The second, diastolic pressure, is the pressure when the heart rests between beats. Both are measured in millimetres of mercury.</p>
<p>Many guidelines consider a reading below 120/80 to be normal, although exact thresholds for diagnosis and treatment differ between countries and depend on a person&#x27;s overall health. High blood pressure usually causes no symptoms, which is why it is often called a silent condition. Over years, it strains the heart and blood vessels and increases the risk of stroke, heart attack and kidney disease.</p>
<h2>Measuring at home</h2>
<p>Sit quietly for five minutes first, with your back supported and feet flat on the floor. Rest your arm at heart level and use a cuff of the correct size. Avoid caffeine, exercise and smoking for 30 minutes beforehand. Take two readings a minute apart and record both.</p>
<h2>What helps</h2>
<p>Reducing salt, staying active, limiting alcohol, maintaining a healthy weight and not smoking all lower blood pressure. When medication is needed, it is very effective. Readings should always be interpreted with a health professional.</p>','A blood pressure reading such as 118/76 has two parts. The first, systolic pressure, is the pressure in your arteries when the heart beats. The second, diastolic pressure, is the pressure when the heart rests between beats. Both are measured in millimetres of mercury.
Many guidelines consider a reading below 120/80 to be normal, although exact thresholds for diagnosis and treatment differ between countries and depend on a person''s overall health. High blood pressure usually causes no symptoms, which is why it is often called a silent condition. Over years, it strains the heart and blood vessels and increases the risk of stroke, heart attack and kidney disease.
Measuring at home
Sit quietly for five minutes first, with your back supported and feet flat on the floor. Rest your arm at heart level and use a cuff of the correct size. Avoid caffeine, exercise and smoking for 30 minutes beforehand. Take two readings a minute apart and record both.
What helps
Reducing salt, staying active, limiting alcohol, maintaining a healthy weight and not smoking all lower blood pressure. When medication is needed, it is very effective. Readings should always be interpreted with a health professional.',3,7,'/media/covers/understanding-blood-pressure-numbers.svg','published','2026-05-06 13:12:40.563957','2026-05-04 13:12:40.563957','2026-10-31 07:12:40.756146',241);
INSERT INTO "documents" VALUES(3,'Note-taking methods compared','note-taking-methods-compared','Cornell notes, outlines and mind maps suit different subjects and learners. The best method is the one that makes you process information, not just copy it.','<p>Good notes are not transcripts. Research suggests that students who summarise and rephrase ideas in their own words tend to understand and remember more than those who try to record everything verbatim. The method matters less than the thinking it encourages.</p>
<p>The Cornell method divides the page into three parts: a main area for notes during the lecture, a narrow column for key questions and terms added afterwards, and a summary at the bottom. The questions column turns notes into a ready-made self-test.</p>
<h2>Outlines and mind maps</h2>
<p>Outlining organises information into headings and indented points, which works well for structured subjects with clear hierarchies, such as history or law. Mind maps place a central idea in the middle and branch out to related concepts, which helps when seeing connections matters, as in brainstorming or revising a topic.</p>
<h2>Handwriting or typing?</h2>
<p>Typing is faster, which can tempt people to transcribe rather than think. Handwriting forces selection and summarising. Either can work well if you focus on processing ideas. Whatever method you choose, reviewing notes within a day or two and turning them into questions makes them far more valuable.</p>','Good notes are not transcripts. Research suggests that students who summarise and rephrase ideas in their own words tend to understand and remember more than those who try to record everything verbatim. The method matters less than the thinking it encourages.
The Cornell method divides the page into three parts: a main area for notes during the lecture, a narrow column for key questions and terms added afterwards, and a summary at the bottom. The questions column turns notes into a ready-made self-test.
Outlines and mind maps
Outlining organises information into headings and indented points, which works well for structured subjects with clear hierarchies, such as history or law. Mind maps place a central idea in the middle and branch out to related concepts, which helps when seeing connections matters, as in brainstorming or revising a topic.
Handwriting or typing?
Typing is faster, which can tempt people to transcribe rather than think. Handwriting forces selection and summarising. Either can work well if you focus on processing ideas. Whatever method you choose, reviewing notes within a day or two and turning them into questions makes them far more valuable.',6,6,'/media/covers/note-taking-methods-compared.svg','published','2026-05-10 05:12:40.563957','2026-05-09 05:12:40.563957','2026-10-31 07:12:40.756146',662);
INSERT INTO "documents" VALUES(4,'How vaccines train the immune system','how-vaccines-train-the-immune-system','Vaccines show the immune system a harmless preview of a germ so it can respond faster to the real thing. Different vaccine types deliver that preview in different ways.','<p>Your immune system learns from experience. The first time it meets a new germ, it takes days to produce antibodies and specialised cells that target it. During that delay, the infection can make you seriously ill. Afterwards, memory cells remain, ready to respond much faster next time.</p>
<p>A vaccine provides that first experience without the disease. It presents the immune system with a recognisable piece of the pathogen, called an antigen, or with instructions to make one.</p>
<h2>Different ways to deliver the preview</h2>
<p>Inactivated vaccines use killed germs. Live attenuated vaccines use weakened versions that cannot cause normal illness in healthy people. Subunit vaccines use only selected proteins. mRNA vaccines deliver short-lived instructions that let your own cells briefly make a harmless protein, which the immune system then learns to recognise.</p>
<h2>Why boosters and coverage matter</h2>
<p>Immune memory can fade, and some viruses change over time, so certain vaccines need boosters or updated versions. When enough people in a community are immune, a germ struggles to spread, which also protects those who cannot be vaccinated, such as very young babies or people with weakened immune systems.</p>','Your immune system learns from experience. The first time it meets a new germ, it takes days to produce antibodies and specialised cells that target it. During that delay, the infection can make you seriously ill. Afterwards, memory cells remain, ready to respond much faster next time.
A vaccine provides that first experience without the disease. It presents the immune system with a recognisable piece of the pathogen, called an antigen, or with instructions to make one.
Different ways to deliver the preview
Inactivated vaccines use killed germs. Live attenuated vaccines use weakened versions that cannot cause normal illness in healthy people. Subunit vaccines use only selected proteins. mRNA vaccines deliver short-lived instructions that let your own cells briefly make a harmless protein, which the immune system then learns to recognise.
Why boosters and coverage matter
Immune memory can fade, and some viruses change over time, so certain vaccines need boosters or updated versions. When enough people in a community are immune, a germ struggles to spread, which also protects those who cannot be vaccinated, such as very young babies or people with weakened immune systems.',2,9,'/media/covers/how-vaccines-train-the-immune-system.svg','published','2026-05-13 00:12:40.563957','2026-05-10 00:12:40.563957','2026-10-31 07:12:40.756146',86);
INSERT INTO "documents" VALUES(5,'Why peer review matters, and where it falls short','why-peer-review-matters-and-where-it-falls-short','Before most research is published, other experts scrutinise it. Peer review catches many problems, but it was never designed to guarantee that a result is true.','<p>When researchers submit a paper to a journal, an editor usually sends it to a few independent experts in the field. These reviewers assess whether the question is important, the methods are appropriate, the analysis supports the conclusions and the work fits into existing knowledge. They often request changes or additional experiments before publication.</p>
<p>Peer review improves papers and filters out many weak studies. It also helps readers who are not specialists, because publication in a reviewed journal signals that at least some experts found the work credible.</p>
<h2>Its limits</h2>
<p>Reviewers rarely have access to raw data or the time to repeat experiments, so fabricated results and subtle errors can slip through. Reviews can be slow, and reviewers can be biased towards familiar ideas or well-known institutions. Positive results are also more likely to be published than null results, which can distort the overall picture.</p>
<h2>Ongoing improvements</h2>
<p>Many journals now encourage or require sharing data and code, and some publish reviews alongside papers. Preprints allow faster sharing before review, though readers should treat them as preliminary. Ultimately, confidence comes from independent replication, not from a single published study.</p>','When researchers submit a paper to a journal, an editor usually sends it to a few independent experts in the field. These reviewers assess whether the question is important, the methods are appropriate, the analysis supports the conclusions and the work fits into existing knowledge. They often request changes or additional experiments before publication.
Peer review improves papers and filters out many weak studies. It also helps readers who are not specialists, because publication in a reviewed journal signals that at least some experts found the work credible.
Its limits
Reviewers rarely have access to raw data or the time to repeat experiments, so fabricated results and subtle errors can slip through. Reviews can be slow, and reviewers can be biased towards familiar ideas or well-known institutions. Positive results are also more likely to be published than null results, which can distort the overall picture.
Ongoing improvements
Many journals now encourage or require sharing data and code, and some publish reviews alongside papers. Preprints allow faster sharing before review, though readers should treat them as preliminary. Ultimately, confidence comes from independent replication, not from a single published study.',2,7,'/media/covers/why-peer-review-matters-and-where-it-falls-short.svg','published','2026-05-16 05:12:40.563957','2026-05-14 05:12:40.563957','2026-10-31 07:12:40.756146',38);
INSERT INTO "documents" VALUES(6,'How much sleep do adults really need?','how-much-sleep-do-adults-really-need','Most adults need at least seven hours a night, yet many get less. What happens during sleep, and practical ways to improve it.','<p>Sleep experts generally recommend that adults get seven or more hours of sleep per night on a regular basis. Individual needs vary a little, but routinely sleeping much less is linked with poorer concentration, mood and immune function, and over the long term with higher risks of conditions such as heart disease and diabetes.</p>
<p>Sleep is not a single state. Through the night you cycle through light sleep, deep slow-wave sleep and REM sleep, the stage most associated with vivid dreams. Deep sleep is important for physical recovery, while REM and other stages contribute to memory and emotional processing.</p>
<h2>Habits that help</h2>
<p>Keep a consistent schedule, including at weekends, so your body clock stays stable. Get daylight in the morning and dim the lights in the evening. A cool, dark, quiet bedroom makes it easier to stay asleep. Caffeine can affect sleep for many hours, so many people do better avoiding it from early afternoon. Alcohol may make you drowsy but tends to fragment sleep later in the night.</p>
<h2>When to talk to a doctor</h2>
<p>Loud snoring with pauses in breathing, persistent insomnia or feeling exhausted despite enough time in bed can signal a sleep disorder that is treatable.</p>','Sleep experts generally recommend that adults get seven or more hours of sleep per night on a regular basis. Individual needs vary a little, but routinely sleeping much less is linked with poorer concentration, mood and immune function, and over the long term with higher risks of conditions such as heart disease and diabetes.
Sleep is not a single state. Through the night you cycle through light sleep, deep slow-wave sleep and REM sleep, the stage most associated with vivid dreams. Deep sleep is important for physical recovery, while REM and other stages contribute to memory and emotional processing.
Habits that help
Keep a consistent schedule, including at weekends, so your body clock stays stable. Get daylight in the morning and dim the lights in the evening. A cool, dark, quiet bedroom makes it easier to stay asleep. Caffeine can affect sleep for many hours, so many people do better avoiding it from early afternoon. Alcohol may make you drowsy but tends to fragment sleep later in the night.
When to talk to a doctor
Loud snoring with pauses in breathing, persistent insomnia or feeling exhausted despite enough time in bed can signal a sleep disorder that is treatable.',3,8,'/media/covers/how-much-sleep-do-adults-really-need.svg','published','2026-05-19 04:12:40.563957','2026-05-15 04:12:40.563957','2026-10-31 07:12:40.756146',134);
INSERT INTO "documents" VALUES(7,'Teaching children about money','teaching-children-about-money','Children form money habits early. Age-appropriate lessons about saving, spending and earning prepare them for financial independence.','<p>Research on financial habits suggests that children begin to form attitudes towards money at a young age, often before they start school. Talking openly about money and giving children chances to practise with small amounts can make a lasting difference.</p>
<p>For young children, the basics are concrete: coins and notes have value, things cost money and sometimes we have to wait to buy what we want. Clear jars labelled for saving, spending and sharing make choices visible.</p>
<h2>As they grow older</h2>
<p>Regular pocket money, whether linked to chores or not, gives children something to manage. Letting them make small mistakes, such as spending everything on the first day, teaches more than any lecture. Teenagers can learn about bank accounts, budgeting for a phone plan, how interest works and the risks of buying now and paying later.</p>
<h2>Lead by example</h2>
<p>Children notice how adults handle money. Explaining decisions, such as comparing prices, saving for a holiday or choosing not to buy something, shows that financial choices involve trade-offs. Many schools now include financial education, but conversations at home remain one of the strongest influences.</p>','Research on financial habits suggests that children begin to form attitudes towards money at a young age, often before they start school. Talking openly about money and giving children chances to practise with small amounts can make a lasting difference.
For young children, the basics are concrete: coins and notes have value, things cost money and sometimes we have to wait to buy what we want. Clear jars labelled for saving, spending and sharing make choices visible.
As they grow older
Regular pocket money, whether linked to chores or not, gives children something to manage. Letting them make small mistakes, such as spending everything on the first day, teaches more than any lecture. Teenagers can learn about bank accounts, budgeting for a phone plan, how interest works and the risks of buying now and paying later.
Lead by example
Children notice how adults handle money. Explaining decisions, such as comparing prices, saving for a holiday or choosing not to buy something, shows that financial choices involve trade-offs. Many schools now include financial education, but conversations at home remain one of the strongest influences.',6,9,'/media/covers/teaching-children-about-money.svg','published','2026-05-21 23:12:40.563957','2026-05-17 23:12:40.563957','2026-10-31 07:12:40.756146',934);
INSERT INTO "documents" VALUES(8,'Critical thinking in an age of misinformation','critical-thinking-in-an-age-of-misinformation','False and misleading information spreads quickly online. A few habits, such as lateral reading and checking original sources, help anyone evaluate claims.','<p>Misinformation is false or misleading content shared without intent to deceive; disinformation is shared deliberately. Both spread quickly on social media, where emotionally charged posts tend to travel furthest. Teaching critical thinking skills is now a priority for many schools.</p>
<p>Professional fact-checkers use a technique called lateral reading. Instead of studying a single website closely to judge whether it seems trustworthy, they open new tabs and look up what other reliable sources say about the claim and the site behind it. This is often faster and more accurate than evaluating a page on its own.</p>
<h2>Useful questions</h2>
<p>Who created this, and what might their motivation be? What is the original source of the claim? Is the image or video being shown in its original context? Do other credible outlets report the same thing? Is the headline supported by the article itself?</p>
<h2>Slowing down</h2>
<p>Strong emotions such as anger or fear are a signal to pause before sharing. Reverse image searches can reveal old photos presented as new. Being willing to say &quot;I&#x27;m not sure yet&quot; is part of thinking critically. These skills apply to all sources, including those we already agree with.</p>','Misinformation is false or misleading content shared without intent to deceive; disinformation is shared deliberately. Both spread quickly on social media, where emotionally charged posts tend to travel furthest. Teaching critical thinking skills is now a priority for many schools.
Professional fact-checkers use a technique called lateral reading. Instead of studying a single website closely to judge whether it seems trustworthy, they open new tabs and look up what other reliable sources say about the claim and the site behind it. This is often faster and more accurate than evaluating a page on its own.
Useful questions
Who created this, and what might their motivation be? What is the original source of the claim? Is the image or video being shown in its original context? Do other credible outlets report the same thing? Is the headline supported by the article itself?
Slowing down
Strong emotions such as anger or fear are a signal to pause before sharing. Reverse image searches can reveal old photos presented as new. Being willing to say "I''m not sure yet" is part of thinking critically. These skills apply to all sources, including those we already agree with.',6,6,'/media/covers/critical-thinking-in-an-age-of-misinformation.svg','published','2026-05-24 11:12:40.563957','2026-05-21 11:12:40.563957','2026-10-31 07:12:40.756146',1706);
INSERT INTO "documents" VALUES(9,'Solar panels: from sunlight to socket','solar-panels-from-sunlight-to-socket','Photovoltaic cells turn sunlight directly into electricity. How the technology works, why costs have fallen so far, and what happens when the sun goes down.','<p>Most solar panels are made of silicon cells. Each cell has two layers treated so that one has extra electrons and the other has a shortage of them. When sunlight hits the cell, it knocks electrons loose, and the electric field between the layers pushes them in one direction, creating a direct current.</p>
<p>An inverter converts that direct current into the alternating current used by homes and the grid. Typical panels convert around a fifth or more of the sunlight that reaches them into electricity, and efficiency continues to improve.</p>
<h2>Why solar has spread so fast</h2>
<p>Manufacturing at enormous scale has driven the cost of solar panels down dramatically over the past few decades. In many sunny regions, new solar farms are now among the cheapest sources of new electricity.</p>
<h2>Handling night and cloudy days</h2>
<p>Solar output follows the sun, so electricity systems balance it with other sources, power lines that move energy between regions, and storage. Battery systems are increasingly used to shift midday solar power into the evening. At home, a rooftop system can be paired with a battery or simply export surplus power to the grid when tariffs allow.</p>','Most solar panels are made of silicon cells. Each cell has two layers treated so that one has extra electrons and the other has a shortage of them. When sunlight hits the cell, it knocks electrons loose, and the electric field between the layers pushes them in one direction, creating a direct current.
An inverter converts that direct current into the alternating current used by homes and the grid. Typical panels convert around a fifth or more of the sunlight that reaches them into electricity, and efficiency continues to improve.
Why solar has spread so fast
Manufacturing at enormous scale has driven the cost of solar panels down dramatically over the past few decades. In many sunny regions, new solar farms are now among the cheapest sources of new electricity.
Handling night and cloudy days
Solar output follows the sun, so electricity systems balance it with other sources, power lines that move energy between regions, and storage. Battery systems are increasingly used to shift midday solar power into the evening. At home, a rooftop system can be paired with a battery or simply export surplus power to the grid when tariffs allow.',4,9,'/media/covers/solar-panels-from-sunlight-to-socket.svg','published','2026-05-28 02:12:40.563957','2026-05-25 02:12:40.563957','2026-10-31 07:12:40.756146',182);
INSERT INTO "documents" VALUES(10,'What makes a good scientific experiment','what-makes-a-good-scientific-experiment','Control groups, randomisation and blinding are not bureaucratic rituals. Each one removes a specific way that we fool ourselves.','<p>A good experiment is designed so that the result can only be explained by the thing being tested. That sounds simple, but many alternative explanations hide in ordinary situations, and the standard tools of experimental design exist to rule them out one by one.</p>
<p>A control group receives everything except the treatment. Without it, improvements might be due to time passing, natural recovery or simply being observed. Random assignment to groups ensures that differences between people, such as age or health, are spread evenly rather than chosen, consciously or not, by the researcher.</p>
<h2>Blinding and placebo</h2>
<p>When participants know they are receiving a treatment, expectations can change how they feel and report results. When researchers know, they may measure or interpret outcomes differently. Blinding one or both sides, often with a placebo, removes these influences.</p>
<h2>Planning before looking</h2>
<p>Deciding the main outcome and the analysis in advance, and calculating how many participants are needed, prevents searching through data until something looks significant. Many studies now pre-register these plans publicly. Finally, an exciting result should be repeated by others before it is trusted: replication is the strongest test of all.</p>','A good experiment is designed so that the result can only be explained by the thing being tested. That sounds simple, but many alternative explanations hide in ordinary situations, and the standard tools of experimental design exist to rule them out one by one.
A control group receives everything except the treatment. Without it, improvements might be due to time passing, natural recovery or simply being observed. Random assignment to groups ensures that differences between people, such as age or health, are spread evenly rather than chosen, consciously or not, by the researcher.
Blinding and placebo
When participants know they are receiving a treatment, expectations can change how they feel and report results. When researchers know, they may measure or interpret outcomes differently. Blinding one or both sides, often with a placebo, removes these influences.
Planning before looking
Deciding the main outcome and the analysis in advance, and calculating how many participants are needed, prevents searching through data until something looks significant. Many studies now pre-register these plans publicly. Finally, an exciting result should be repeated by others before it is trusted: replication is the strongest test of all.',2,9,'/media/covers/what-makes-a-good-scientific-experiment.svg','published','2026-05-30 20:12:40.563957','2026-05-28 20:12:40.563957','2026-10-31 07:12:40.756146',1729);
INSERT INTO "documents" VALUES(11,'What a chip shortage teaches us about supply chains','what-a-chip-shortage-teaches-us-about-supply-chains','When semiconductors ran short, cars and consoles were delayed worldwide. The episode revealed how concentrated and slow-moving chip production is.','<p>Semiconductors are in almost everything with a battery or a plug, from cars and washing machines to medical devices. When demand for electronics surged and factories faced disruptions in the early 2020s, shortages rippled across industries that had never thought of themselves as chip buyers.</p>
<p>Making chips is unusually hard to scale quickly. A modern fabrication plant costs many billions of dollars and takes years to build and equip. The most advanced manufacturing is concentrated in a few companies and regions, and some of the specialised machines involved come from a single supplier.</p>
<h2>Why cars were hit hard</h2>
<p>Car makers often used just-in-time ordering and older, cheaper chips. When they cut orders early in the pandemic, chip factories reassigned capacity to consumer electronics. When car demand returned, the capacity was not there, and a missing part worth a few dollars could leave a vehicle unfinished.</p>
<h2>Lessons businesses took away</h2>
<p>Companies have since increased buffer stocks for critical parts, signed longer-term supply agreements and designed products that can use alternative components. Governments in several regions have also funded new factories to reduce dependence on a small number of locations.</p>','Semiconductors are in almost everything with a battery or a plug, from cars and washing machines to medical devices. When demand for electronics surged and factories faced disruptions in the early 2020s, shortages rippled across industries that had never thought of themselves as chip buyers.
Making chips is unusually hard to scale quickly. A modern fabrication plant costs many billions of dollars and takes years to build and equip. The most advanced manufacturing is concentrated in a few companies and regions, and some of the specialised machines involved come from a single supplier.
Why cars were hit hard
Car makers often used just-in-time ordering and older, cheaper chips. When they cut orders early in the pandemic, chip factories reassigned capacity to consumer electronics. When car demand returned, the capacity was not there, and a missing part worth a few dollars could leave a vehicle unfinished.
Lessons businesses took away
Companies have since increased buffer stocks for critical parts, signed longer-term supply agreements and designed products that can use alternative components. Governments in several regions have also funded new factories to reduce dependence on a small number of locations.',1,7,'/media/covers/what-a-chip-shortage-teaches-us-about-supply-chains.svg','draft',NULL,'2026-06-01 23:12:40.563957','2026-06-02 23:12:40.563957',0);
INSERT INTO "documents" VALUES(12,'Food waste: where it happens and how to cut it','food-waste-where-it-happens-and-how-to-cut-it','A large share of the food produced worldwide is never eaten. Losses happen on farms, in shops and in homes, and each stage has practical fixes.','<p>Food is lost or wasted at every step between the field and the plate. On farms and in storage, crops can be damaged by pests, weather or a lack of cooling. In shops, produce that looks imperfect or is close to its date may be thrown away. In homes, food is forgotten at the back of the fridge, cooked in excess or discarded because of confusion over date labels.</p>
<p>Wasted food also wastes the land, water, energy and labour used to produce it. When it rots in landfill, it releases methane, a potent greenhouse gas. Reducing food waste is therefore one of the simpler ways to lower environmental impact.</p>
<h2>At home</h2>
<p>Plan meals and shop with a list. Store food correctly and keep older items at the front. Learn the difference between labels: &quot;use by&quot; relates to safety, while &quot;best before&quot; relates to quality, and food is often fine after that date. Freeze leftovers and bread before they spoil.</p>
<h2>Beyond the kitchen</h2>
<p>Supermarkets increasingly sell imperfect produce at lower prices and donate surplus to food banks. Unavoidable scraps can be composted or collected for anaerobic digestion, which turns them into biogas and fertiliser.</p>','Food is lost or wasted at every step between the field and the plate. On farms and in storage, crops can be damaged by pests, weather or a lack of cooling. In shops, produce that looks imperfect or is close to its date may be thrown away. In homes, food is forgotten at the back of the fridge, cooked in excess or discarded because of confusion over date labels.
Wasted food also wastes the land, water, energy and labour used to produce it. When it rots in landfill, it releases methane, a potent greenhouse gas. Reducing food waste is therefore one of the simpler ways to lower environmental impact.
At home
Plan meals and shop with a list. Store food correctly and keep older items at the front. Learn the difference between labels: "use by" relates to safety, while "best before" relates to quality, and food is often fine after that date. Freeze leftovers and bread before they spoil.
Beyond the kitchen
Supermarkets increasingly sell imperfect produce at lower prices and donate surplus to food banks. Unavoidable scraps can be composted or collected for anaerobic digestion, which turns them into biogas and fertiliser.',4,8,'/media/covers/food-waste-where-it-happens-and-how-to-cut-it.svg','published','2026-06-05 12:12:40.563957','2026-06-03 12:12:40.563957','2026-10-31 07:12:40.756146',813);
INSERT INTO "documents" VALUES(13,'The ocean''s role in regulating the climate','the-ocean-s-role-in-regulating-the-climate','The ocean absorbs most of the extra heat trapped by greenhouse gases and a large share of our carbon dioxide. That service comes at a cost to marine life.','<p>The ocean covers about 70 percent of Earth&#x27;s surface and stores vast amounts of heat. Water has a high heat capacity, so it warms and cools slowly, which moderates temperatures on nearby land. Ocean currents carry warm water from the tropics towards the poles and bring colder water back, shaping regional climates.</p>
<p>As greenhouse gases trap extra energy in the climate system, the ocean has absorbed the large majority of that excess heat. This has slowed warming on land, but it has also raised ocean temperatures, causing marine heatwaves and contributing to sea-level rise as water expands.</p>
<h2>A carbon sink with side effects</h2>
<p>The ocean also absorbs a substantial share of the carbon dioxide released by human activities. When carbon dioxide dissolves in seawater, it forms carbonic acid, making the water more acidic. This makes it harder for corals, shellfish and some plankton to build their calcium carbonate shells and skeletons.</p>
<h2>Why it matters</h2>
<p>Healthy oceans support fisheries, coastal protection and much of the oxygen produced by photosynthesis on Earth. Reducing emissions, protecting marine areas and restoring coastal ecosystems such as mangroves and seagrass meadows all help the ocean continue its stabilising role.</p>','The ocean covers about 70 percent of Earth''s surface and stores vast amounts of heat. Water has a high heat capacity, so it warms and cools slowly, which moderates temperatures on nearby land. Ocean currents carry warm water from the tropics towards the poles and bring colder water back, shaping regional climates.
As greenhouse gases trap extra energy in the climate system, the ocean has absorbed the large majority of that excess heat. This has slowed warming on land, but it has also raised ocean temperatures, causing marine heatwaves and contributing to sea-level rise as water expands.
A carbon sink with side effects
The ocean also absorbs a substantial share of the carbon dioxide released by human activities. When carbon dioxide dissolves in seawater, it forms carbonic acid, making the water more acidic. This makes it harder for corals, shellfish and some plankton to build their calcium carbonate shells and skeletons.
Why it matters
Healthy oceans support fisheries, coastal protection and much of the oxygen produced by photosynthesis on Earth. Reducing emissions, protecting marine areas and restoring coastal ecosystems such as mangroves and seagrass meadows all help the ocean continue its stabilising role.',4,6,'/media/covers/the-ocean-s-role-in-regulating-the-climate.svg','published','2026-06-08 14:12:40.563957','2026-06-06 14:12:40.563957','2026-10-31 07:12:40.756146',351);
INSERT INTO "documents" VALUES(14,'Remote work after the great experiment','remote-work-after-the-great-experiment','Many office workers went remote almost overnight, and hybrid arrangements are now common. What has research and experience taught employers and employees?','<p>When offices closed suddenly in 2020, millions of people discovered that much of their work could be done from home. Since then, many organisations have settled on hybrid arrangements, with some days in the office and some at home, while others have returned fully to the office or gone fully remote.</p>
<p>Workers commonly report that remote work saves commuting time and money and gives them more control over their day. Employers can recruit from a wider area and may reduce office costs. On the other hand, some people find it harder to separate work from home life, and new employees can miss out on informal learning that happens naturally in a shared space.</p>
<h2>What seems to work</h2>
<p>Teams that do well remotely tend to be deliberate: they document decisions, agree on core hours for collaboration, keep meetings purposeful and use office days for activities that benefit from being together, such as onboarding, planning and creative work.</p>
<h2>Career considerations</h2>
<p>Visibility still matters. Remote workers can protect their progression by sharing results regularly, building relationships across the organisation and asking for clear goals. For employers, measuring outcomes rather than hours online tends to be fairer and more effective.</p>','When offices closed suddenly in 2020, millions of people discovered that much of their work could be done from home. Since then, many organisations have settled on hybrid arrangements, with some days in the office and some at home, while others have returned fully to the office or gone fully remote.
Workers commonly report that remote work saves commuting time and money and gives them more control over their day. Employers can recruit from a wider area and may reduce office costs. On the other hand, some people find it harder to separate work from home life, and new employees can miss out on informal learning that happens naturally in a shared space.
What seems to work
Teams that do well remotely tend to be deliberate: they document decisions, agree on core hours for collaboration, keep meetings purposeful and use office days for activities that benefit from being together, such as onboarding, planning and creative work.
Career considerations
Visibility still matters. Remote workers can protect their progression by sharing results regularly, building relationships across the organisation and asking for clear goals. For employers, measuring outcomes rather than hours online tends to be fairer and more effective.',5,7,'/media/covers/remote-work-after-the-great-experiment.svg','published','2026-06-12 02:12:40.563957','2026-06-08 02:12:40.563957','2026-10-31 07:12:40.756146',74);
INSERT INTO "documents" VALUES(15,'How heat pumps heat and cool a home','how-heat-pumps-heat-and-cool-a-home','A heat pump moves heat instead of making it, which is why it can deliver several units of heat for every unit of electricity it uses.','<p>A heat pump works on the same principle as a refrigerator, only in reverse. A refrigerant circulates through a loop. Outside, it evaporates at a low temperature and absorbs heat from the air, even on a cold day. A compressor then squeezes the gas, raising its temperature. Indoors, the hot refrigerant releases its heat into the home and condenses back into a liquid, ready to repeat the cycle.</p>
<p>Because it moves heat rather than generating it by burning fuel or running a simple electric heater, a heat pump can deliver several units of heat for every unit of electricity it uses. This ratio is called the coefficient of performance. It falls as outdoor temperatures drop, but modern models are designed to keep working in cold climates.</p>
<h2>Cooling as well</h2>
<p>Most air-source heat pumps can reverse the cycle in summer and act as air conditioners, moving heat out of the home.</p>
<h2>Getting the best results</h2>
<p>Heat pumps work most efficiently at lower flow temperatures, so good insulation, appropriately sized radiators or underfloor heating, and correct installation make a big difference. When powered by electricity from low-carbon sources, they can cut heating emissions substantially compared with fossil fuel boilers.</p>','A heat pump works on the same principle as a refrigerator, only in reverse. A refrigerant circulates through a loop. Outside, it evaporates at a low temperature and absorbs heat from the air, even on a cold day. A compressor then squeezes the gas, raising its temperature. Indoors, the hot refrigerant releases its heat into the home and condenses back into a liquid, ready to repeat the cycle.
Because it moves heat rather than generating it by burning fuel or running a simple electric heater, a heat pump can deliver several units of heat for every unit of electricity it uses. This ratio is called the coefficient of performance. It falls as outdoor temperatures drop, but modern models are designed to keep working in cold climates.
Cooling as well
Most air-source heat pumps can reverse the cycle in summer and act as air conditioners, moving heat out of the home.
Getting the best results
Heat pumps work most efficiently at lower flow temperatures, so good insulation, appropriately sized radiators or underfloor heating, and correct installation make a big difference. When powered by electricity from low-carbon sources, they can cut heating emissions substantially compared with fossil fuel boilers.',4,7,'/media/covers/how-heat-pumps-heat-and-cool-a-home.svg','published','2026-06-14 19:12:40.563957','2026-06-11 19:12:40.563957','2026-10-31 07:12:40.756146',1265);
INSERT INTO "documents" VALUES(16,'Small businesses and the cash flow trap','small-businesses-and-the-cash-flow-trap','Profitable small businesses still fail when cash runs out. Understanding the timing of money in and money out is essential for survival.','<p>Cash flow is the movement of money into and out of a business. A company can be profitable on paper and still fail if it cannot pay suppliers, staff and rent on time. This happens surprisingly often, especially when sales grow quickly.</p>
<p>The problem is timing. A business may pay for materials and labour weeks or months before customers pay their invoices. Rapid growth makes the gap larger: more orders mean more money spent upfront while receipts are still on the way.</p>
<h2>Practical ways to stay ahead</h2>
<p>Create a simple cash flow forecast for the coming weeks and months, listing expected income and payments. Invoice promptly, set clear payment terms and follow up on late payments. Ask larger customers for deposits or staged payments, and negotiate longer terms with suppliers where possible. Keep a cash reserve for slow months.</p>
<h2>Warning signs</h2>
<p>Regularly relying on overdrafts to pay routine bills, delaying tax payments or struggling to pay suppliers on time are signals to act early. An accountant or small business adviser can help review pricing, costs and financing options before a temporary squeeze becomes a crisis.</p>','Cash flow is the movement of money into and out of a business. A company can be profitable on paper and still fail if it cannot pay suppliers, staff and rent on time. This happens surprisingly often, especially when sales grow quickly.
The problem is timing. A business may pay for materials and labour weeks or months before customers pay their invoices. Rapid growth makes the gap larger: more orders mean more money spent upfront while receipts are still on the way.
Practical ways to stay ahead
Create a simple cash flow forecast for the coming weeks and months, listing expected income and payments. Invoice promptly, set clear payment terms and follow up on late payments. Ask larger customers for deposits or staged payments, and negotiate longer terms with suppliers where possible. Keep a cash reserve for slow months.
Warning signs
Regularly relying on overdrafts to pay routine bills, delaying tax payments or struggling to pay suppliers on time are signals to act early. An accountant or small business adviser can help review pricing, costs and financing options before a temporary squeeze becomes a crisis.',5,7,'/media/covers/small-businesses-and-the-cash-flow-trap.svg','published','2026-06-17 11:12:40.563957','2026-06-15 11:12:40.563957','2026-10-31 07:12:40.756146',587);
INSERT INTO "documents" VALUES(17,'Why your phone battery wears out, and how to slow it down','why-your-phone-battery-wears-out-and-how-to-slow-it-down','Lithium-ion batteries lose capacity with every cycle, and heat speeds the process up. A few habits can noticeably extend their useful life.','<p>Almost every phone uses a lithium-ion battery. Charging pushes lithium ions into the graphite of one electrode; using the phone lets them flow back. Each cycle causes tiny side reactions that consume some lithium and build up layers on the electrodes, so the battery slowly holds less charge.</p>
<p>Two conditions accelerate this ageing more than anything else: high temperature and spending long periods at a very high or very low state of charge. A battery left at full charge in a hot car ages much faster than one kept cool at half charge.</p>
<h2>Habits that help</h2>
<p>Avoid leaving the phone in direct sun or charging it under a pillow. Fast charging is convenient and generally safe, but it produces more heat, so slower charging overnight is gentler. Many phones now offer an optimised or limited charging option that pauses at around 80 percent until you need it; turning it on is one of the easiest wins.</p>
<h2>When to replace it</h2>
<p>A worn battery is normal, not a defect. If the phone shuts down unexpectedly or lasts only part of a day, replacing the battery is usually far cheaper, and less wasteful, than replacing the whole device.</p>','Almost every phone uses a lithium-ion battery. Charging pushes lithium ions into the graphite of one electrode; using the phone lets them flow back. Each cycle causes tiny side reactions that consume some lithium and build up layers on the electrodes, so the battery slowly holds less charge.
Two conditions accelerate this ageing more than anything else: high temperature and spending long periods at a very high or very low state of charge. A battery left at full charge in a hot car ages much faster than one kept cool at half charge.
Habits that help
Avoid leaving the phone in direct sun or charging it under a pillow. Fast charging is convenient and generally safe, but it produces more heat, so slower charging overnight is gentler. Many phones now offer an optimised or limited charging option that pauses at around 80 percent until you need it; turning it on is one of the easiest wins.
When to replace it
A worn battery is normal, not a defect. If the phone shuts down unexpectedly or lasts only part of a day, replacing the battery is usually far cheaper, and less wasteful, than replacing the whole device.',1,9,'/media/covers/why-your-phone-battery-wears-out-and-how-to-slow-it-down.svg','published','2026-06-20 21:12:40.563957','2026-06-19 21:12:40.563957','2026-10-31 07:12:40.756146',53);
INSERT INTO "documents" VALUES(18,'Building an exercise habit that lasts','building-an-exercise-habit-that-lasts','Motivation fades; routines remain. Behaviour research suggests starting smaller than you think and making activity easy to repeat.','<p>Many people start an exercise plan with enthusiasm and stop within weeks. The problem is rarely knowledge about what to do. It is that ambitious plans depend on motivation, which naturally rises and falls.</p>
<p>Habits form when a behaviour is repeated in a stable context. Linking exercise to an existing routine, such as a walk straight after lunch or a short workout after your morning coffee, gives it a reliable cue. Starting small matters: ten minutes you actually do beats an hour you keep postponing.</p>
<h2>Make it easy and rewarding</h2>
<p>Reduce friction by preparing clothes the night before or choosing activities close to home. Pick forms of movement you enjoy, because enjoyment predicts consistency better than intensity does. Tracking sessions on a calendar can provide a satisfying sense of progress.</p>
<h2>How much is enough</h2>
<p>Public health guidance for adults commonly suggests at least 150 minutes of moderate activity a week, such as brisk walking, plus muscle-strengthening activities on two or more days. Any amount above zero brings benefits, especially for people who are currently inactive.</p>
<p>If you miss a day, simply resume. Research on habit formation suggests occasional lapses do not undo progress; abandoning the plan entirely does.</p>','Many people start an exercise plan with enthusiasm and stop within weeks. The problem is rarely knowledge about what to do. It is that ambitious plans depend on motivation, which naturally rises and falls.
Habits form when a behaviour is repeated in a stable context. Linking exercise to an existing routine, such as a walk straight after lunch or a short workout after your morning coffee, gives it a reliable cue. Starting small matters: ten minutes you actually do beats an hour you keep postponing.
Make it easy and rewarding
Reduce friction by preparing clothes the night before or choosing activities close to home. Pick forms of movement you enjoy, because enjoyment predicts consistency better than intensity does. Tracking sessions on a calendar can provide a satisfying sense of progress.
How much is enough
Public health guidance for adults commonly suggests at least 150 minutes of moderate activity a week, such as brisk walking, plus muscle-strengthening activities on two or more days. Any amount above zero brings benefits, especially for people who are currently inactive.
If you miss a day, simply resume. Research on habit formation suggests occasional lapses do not undo progress; abandoning the plan entirely does.',3,9,'/media/covers/building-an-exercise-habit-that-lasts.svg','published','2026-06-24 00:12:40.563957','2026-06-23 00:12:40.563957','2026-10-31 07:12:40.756146',921);
INSERT INTO "documents" VALUES(19,'Spaced repetition: study less, remember more','spaced-repetition-study-less-remember-more','Reviewing material at increasing intervals fights the natural forgetting curve. It is one of the best-supported techniques in learning science.','<p>In the nineteenth century, psychologist Hermann Ebbinghaus memorised lists of nonsense syllables and tested himself at different intervals. He found that forgetting is rapid at first and then slows down, a pattern now called the forgetting curve. He also found that each review made the memory last longer.</p>
<p>Spaced repetition uses this insight. Instead of cramming the same material many times in one sitting, you review it at increasing intervals: perhaps after a day, then three days, then a week, then a month. Each review comes just as the memory begins to fade, which strengthens it more than reviewing something you still remember easily.</p>
<h2>Putting it into practice</h2>
<p>Flashcard apps can schedule reviews automatically based on how easily you recall each card. Without an app, you can plan review sessions in a calendar or keep cards in boxes reviewed at different frequencies. Spacing works for vocabulary, formulas, definitions and concepts.</p>
<h2>Why cramming feels better</h2>
<p>Massed practice creates a feeling of fluency during the session, so it seems effective. But that fluency fades quickly. Spaced practice feels harder because you have partly forgotten, and that effort is exactly what makes the learning durable.</p>','In the nineteenth century, psychologist Hermann Ebbinghaus memorised lists of nonsense syllables and tested himself at different intervals. He found that forgetting is rapid at first and then slows down, a pattern now called the forgetting curve. He also found that each review made the memory last longer.
Spaced repetition uses this insight. Instead of cramming the same material many times in one sitting, you review it at increasing intervals: perhaps after a day, then three days, then a week, then a month. Each review comes just as the memory begins to fade, which strengthens it more than reviewing something you still remember easily.
Putting it into practice
Flashcard apps can schedule reviews automatically based on how easily you recall each card. Without an app, you can plan review sessions in a calendar or keep cards in boxes reviewed at different frequencies. Spacing works for vocabulary, formulas, definitions and concepts.
Why cramming feels better
Massed practice creates a feeling of fluency during the session, so it seems effective. But that fluency fades quickly. Spaced practice feels harder because you have partly forgotten, and that effort is exactly what makes the learning durable.',6,8,'/media/covers/spaced-repetition-study-less-remember-more.svg','published','2026-06-26 21:12:40.563957','2026-06-22 21:12:40.563957','2026-10-31 07:12:40.756146',1427);
INSERT INTO "documents" VALUES(20,'Two-factor authentication: which method should you choose?','two-factor-authentication-which-method-should-you-choose','Text-message codes, authenticator apps and security keys all add a second step to logging in, but they are not equally strong.','<p>Two-factor authentication asks for something in addition to your password, so a leaked password alone is not enough to take over your account. The second factor comes in several forms, and the differences matter.</p>
<p>SMS codes are the most familiar. They are far better than nothing, but they can be intercepted through SIM-swap fraud, where a criminal convinces a carrier to move your number to their card. They can also be typed into a convincing phishing page.</p>
<h2>Authenticator apps</h2>
<p>Apps that generate six-digit codes every 30 seconds are not tied to your phone number, which removes the SIM-swap risk. Push-notification apps are convenient, but be wary of approving a request you did not start; attackers sometimes send repeated prompts hoping someone taps &quot;approve&quot; to make them stop.</p>
<h2>Security keys and passkeys</h2>
<p>Hardware security keys and passkeys check the website&#x27;s real address before responding, which makes them resistant to phishing. For email, banking and your password manager, they are the strongest option most people can use.</p>
<p>Whatever you choose, save the recovery codes somewhere safe and offline. Losing your only second factor is the most common way people lock themselves out.</p>','Two-factor authentication asks for something in addition to your password, so a leaked password alone is not enough to take over your account. The second factor comes in several forms, and the differences matter.
SMS codes are the most familiar. They are far better than nothing, but they can be intercepted through SIM-swap fraud, where a criminal convinces a carrier to move your number to their card. They can also be typed into a convincing phishing page.
Authenticator apps
Apps that generate six-digit codes every 30 seconds are not tied to your phone number, which removes the SIM-swap risk. Push-notification apps are convenient, but be wary of approving a request you did not start; attackers sometimes send repeated prompts hoping someone taps "approve" to make them stop.
Security keys and passkeys
Hardware security keys and passkeys check the website''s real address before responding, which makes them resistant to phishing. For email, banking and your password manager, they are the strongest option most people can use.
Whatever you choose, save the recovery codes somewhere safe and offline. Losing your only second factor is the most common way people lock themselves out.',1,6,'/media/covers/two-factor-authentication-which-method-should-you-choose.svg','published','2026-06-29 23:12:40.563957','2026-06-28 23:12:40.563957','2026-10-31 07:12:40.756146',1337);
INSERT INTO "documents" VALUES(21,'Walking: the most underrated exercise','walking-the-most-underrated-exercise','Walking needs no equipment or gym membership, yet regular brisk walks improve heart health, mood and longevity. How to get more from every step.','<p>Walking rarely gets the attention of marathon training or high-intensity workouts, but it is one of the most studied forms of physical activity. Regular walking is associated with lower risks of heart disease, stroke, type 2 diabetes and depression, and it supports healthy bones and joints.</p>
<p>Its biggest advantage is accessibility. It needs no special skills or equipment, carries a low risk of injury and fits into everyday life: walking to the shops, taking calls on foot or getting off the bus a stop early.</p>
<h2>Making walks count</h2>
<p>Pace matters. A brisk walk, where you can talk but not sing, counts as moderate-intensity exercise. Adding hills or short faster intervals raises the challenge. Step counts can be motivating, but there is nothing magical about 10,000 steps; research shows benefits increase gradually from much lower daily totals.</p>
<h2>Beyond physical health</h2>
<p>Walking outdoors, especially in green spaces, is linked with lower stress and better mood. Walking with friends adds social connection, and some people find it helps them think through problems. For anyone returning to activity after illness or a long break, walking is often the ideal starting point.</p>','Walking rarely gets the attention of marathon training or high-intensity workouts, but it is one of the most studied forms of physical activity. Regular walking is associated with lower risks of heart disease, stroke, type 2 diabetes and depression, and it supports healthy bones and joints.
Its biggest advantage is accessibility. It needs no special skills or equipment, carries a low risk of injury and fits into everyday life: walking to the shops, taking calls on foot or getting off the bus a stop early.
Making walks count
Pace matters. A brisk walk, where you can talk but not sing, counts as moderate-intensity exercise. Adding hills or short faster intervals raises the challenge. Step counts can be motivating, but there is nothing magical about 10,000 steps; research shows benefits increase gradually from much lower daily totals.
Beyond physical health
Walking outdoors, especially in green spaces, is linked with lower stress and better mood. Walking with friends adds social connection, and some people find it helps them think through problems. For anyone returning to activity after illness or a long break, walking is often the ideal starting point.',3,9,'/media/covers/walking-the-most-underrated-exercise.svg','published','2026-07-03 01:12:40.563957','2026-06-30 01:12:40.563957','2026-10-31 07:12:40.756146',179);
INSERT INTO "documents" VALUES(22,'Why the sky is blue and sunsets are red','why-the-sky-is-blue-and-sunsets-are-red','Sunlight contains every colour, but air molecules scatter short blue wavelengths far more than red ones. The same effect paints the evening sky.','<p>Sunlight looks white, but it is a mixture of all visible colours. As it passes through the atmosphere, it meets nitrogen and oxygen molecules that are much smaller than the wavelength of light. These molecules scatter light in all directions, and they scatter shorter wavelengths far more strongly than longer ones. This is called Rayleigh scattering.</p>
<p>Blue light has a short wavelength, so it is scattered across the whole sky and reaches your eyes from every direction. That is why the sky looks blue during the day. Violet is scattered even more, but sunlight contains less of it, some is absorbed high in the atmosphere, and our eyes are less sensitive to it.</p>
<h2>Red and orange evenings</h2>
<p>When the Sun is low, its light travels through much more air before reaching you. Most of the blue is scattered out of the direct beam along the way, leaving the longer orange and red wavelengths. Dust, smoke and other particles can intensify the colours.</p>
<p>The same physics explains why distant mountains look bluish and why the Moon&#x27;s sky, with no atmosphere, is black even in daylight.</p>','Sunlight looks white, but it is a mixture of all visible colours. As it passes through the atmosphere, it meets nitrogen and oxygen molecules that are much smaller than the wavelength of light. These molecules scatter light in all directions, and they scatter shorter wavelengths far more strongly than longer ones. This is called Rayleigh scattering.
Blue light has a short wavelength, so it is scattered across the whole sky and reaches your eyes from every direction. That is why the sky looks blue during the day. Violet is scattered even more, but sunlight contains less of it, some is absorbed high in the atmosphere, and our eyes are less sensitive to it.
Red and orange evenings
When the Sun is low, its light travels through much more air before reaching you. Most of the blue is scattered out of the direct beam along the way, leaving the longer orange and red wavelengths. Dust, smoke and other particles can intensify the colours.
The same physics explains why distant mountains look bluish and why the Moon''s sky, with no atmosphere, is black even in daylight.',2,8,'/media/covers/why-the-sky-is-blue-and-sunsets-are-red.svg','published','2026-07-06 01:12:40.563957','2026-07-02 01:12:40.563957','2026-10-31 07:12:40.756146',271);
INSERT INTO "documents" VALUES(23,'Choosing a university major','choosing-a-university-major','Choosing a field of study can feel like a lifelong decision, but most careers are more flexible than that. Interests, skills and exploration all deserve weight.','<p>Choosing a major is one of the first big decisions many students make, and it can feel as if it will determine the rest of their life. In reality, many graduates work in fields not directly related to their degree, and skills such as writing, analysis and teamwork transfer across careers.</p>
<p>Start with interests and strengths. Which subjects do you enjoy enough to study in depth for several years? Where do you perform well? Motivation matters, because sustained interest makes demanding coursework more manageable and more rewarding.</p>
<h2>Gather information</h2>
<p>Read course descriptions and talk to current students and faculty. Look at what graduates from different programmes go on to do, while remembering that averages hide wide variation. Internships, volunteering and part-time work give a realistic picture of different fields.</p>
<h2>Keep options open</h2>
<p>Many universities allow students to explore before declaring a major or to combine subjects through minors and joint programmes. Changing direction is common and not a failure. Developing broadly useful skills, building relationships with mentors and staying curious will matter long after the choice of major.</p>','Choosing a major is one of the first big decisions many students make, and it can feel as if it will determine the rest of their life. In reality, many graduates work in fields not directly related to their degree, and skills such as writing, analysis and teamwork transfer across careers.
Start with interests and strengths. Which subjects do you enjoy enough to study in depth for several years? Where do you perform well? Motivation matters, because sustained interest makes demanding coursework more manageable and more rewarding.
Gather information
Read course descriptions and talk to current students and faculty. Look at what graduates from different programmes go on to do, while remembering that averages hide wide variation. Internships, volunteering and part-time work give a realistic picture of different fields.
Keep options open
Many universities allow students to explore before declaring a major or to combine subjects through minors and joint programmes. Changing direction is common and not a failure. Developing broadly useful skills, building relationships with mentors and staying curious will matter long after the choice of major.',6,9,'/media/covers/choosing-a-university-major.svg','draft',NULL,'2026-07-04 19:12:40.563957','2026-07-08 19:12:40.563957',0);
INSERT INTO "documents" VALUES(24,'Fibre: the nutrient most diets lack','fibre-the-nutrient-most-diets-lack','Fibre supports digestion, steadies blood sugar and feeds helpful gut bacteria. Most people eat far less than recommended, but small swaps add up.','<p>Dietary fibre is the part of plant foods that our own enzymes cannot digest. That does not make it useless. Soluble fibre, found in oats, beans and many fruits, forms a gel that slows digestion and can help lower cholesterol. Insoluble fibre, found in whole grains, nuts and vegetable skins, adds bulk and helps food move through the gut.</p>
<p>Fibre also feeds bacteria in the large intestine. As they ferment it, they produce short-chain fatty acids that nourish the cells lining the colon. Diets rich in fibre are associated with lower risks of heart disease, type 2 diabetes and bowel cancer.</p>
<h2>Easy ways to eat more</h2>
<p>Choose whole-grain bread, pasta and rice instead of refined versions. Add beans, lentils or chickpeas to soups and salads. Keep fruit and vegetables with their skins where practical, and snack on nuts or seeds.</p>
<h2>Go gradually</h2>
<p>A sudden jump in fibre can cause bloating and wind while your gut bacteria adjust. Increase intake over a few weeks and drink enough fluids. People with certain digestive conditions should follow advice from their doctor or dietitian.</p>','Dietary fibre is the part of plant foods that our own enzymes cannot digest. That does not make it useless. Soluble fibre, found in oats, beans and many fruits, forms a gel that slows digestion and can help lower cholesterol. Insoluble fibre, found in whole grains, nuts and vegetable skins, adds bulk and helps food move through the gut.
Fibre also feeds bacteria in the large intestine. As they ferment it, they produce short-chain fatty acids that nourish the cells lining the colon. Diets rich in fibre are associated with lower risks of heart disease, type 2 diabetes and bowel cancer.
Easy ways to eat more
Choose whole-grain bread, pasta and rice instead of refined versions. Add beans, lentils or chickpeas to soups and salads. Keep fruit and vegetables with their skins where practical, and snack on nuts or seeds.
Go gradually
A sudden jump in fibre can cause bloating and wind while your gut bacteria adjust. Increase intake over a few weeks and drink enough fluids. People with certain digestive conditions should follow advice from their doctor or dietitian.',3,6,'/media/covers/fibre-the-nutrient-most-diets-lack.svg','published','2026-07-12 03:12:40.563957','2026-07-09 03:12:40.563957','2026-10-31 07:12:40.756146',781);
INSERT INTO "documents" VALUES(25,'Inflation explained with a grocery basket','inflation-explained-with-a-grocery-basket','Inflation measures how the price of a typical basket of goods changes over time. What causes it, how it is measured, and why a little is considered normal.','<p>Imagine buying the same basket of groceries, transport, rent and other everyday items every month. If the basket costs more this year than last year, prices have risen on average. That average increase is inflation. Statistics offices track it with a consumer price index based on what typical households actually buy.</p>
<p>Inflation can be driven by demand, when people and businesses want to buy more than the economy can produce, or by costs, when inputs such as energy, materials or wages become more expensive. Expectations matter too: if everyone expects prices to rise, businesses raise prices and workers ask for higher pay, which can keep inflation going.</p>
<h2>Why not zero?</h2>
<p>Many central banks aim for low and stable inflation, often around 2 percent a year, rather than zero. A small positive rate gives room to cut interest rates in downturns and avoids deflation, where falling prices can encourage people to delay spending and deepen a slump.</p>
<h2>Who is affected</h2>
<p>High inflation erodes savings held in cash and hurts people whose incomes do not keep up. Borrowers with fixed-rate debt may benefit, because the real value of what they owe shrinks. Your personal inflation rate also depends on what you buy, which is why official figures can feel different from everyday experience.</p>','Imagine buying the same basket of groceries, transport, rent and other everyday items every month. If the basket costs more this year than last year, prices have risen on average. That average increase is inflation. Statistics offices track it with a consumer price index based on what typical households actually buy.
Inflation can be driven by demand, when people and businesses want to buy more than the economy can produce, or by costs, when inputs such as energy, materials or wages become more expensive. Expectations matter too: if everyone expects prices to rise, businesses raise prices and workers ask for higher pay, which can keep inflation going.
Why not zero?
Many central banks aim for low and stable inflation, often around 2 percent a year, rather than zero. A small positive rate gives room to cut interest rates in downturns and avoids deflation, where falling prices can encourage people to delay spending and deepen a slump.
Who is affected
High inflation erodes savings held in cash and hurts people whose incomes do not keep up. Borrowers with fixed-rate debt may benefit, because the real value of what they owe shrinks. Your personal inflation rate also depends on what you buy, which is why official figures can feel different from everyday experience.',5,7,'/media/covers/inflation-explained-with-a-grocery-basket.svg','published','2026-07-15 03:12:40.563957','2026-07-13 03:12:40.563957','2026-10-31 07:12:40.756146',114);
INSERT INTO "documents" VALUES(26,'What stress does to the body','what-stress-does-to-the-body','The stress response evolved for short emergencies. When it stays switched on for weeks, it affects sleep, digestion, mood and more.','<p>When you face a threat, your body releases adrenaline and cortisol. Heart rate and breathing speed up, muscles tense and energy is redirected from digestion to readiness. This fight-or-flight response is helpful for short emergencies, such as stepping back from a speeding car.</p>
<p>Problems arise when stressors are constant, such as work pressure, money worries or caring responsibilities. The stress system stays partially activated, and its effects accumulate: disturbed sleep, headaches, muscle tension, digestive problems, irritability and difficulty concentrating are common. Over time, chronic stress is associated with higher blood pressure and a greater risk of anxiety and depression.</p>
<h2>What helps the body reset</h2>
<p>Physical activity uses up stress hormones and improves mood. Slow breathing, with longer exhalations than inhalations, activates the parasympathetic nervous system, which calms the body. Regular sleep, time outdoors and social connection all act as buffers.</p>
<h2>Changing the source</h2>
<p>Techniques help, but so does addressing the cause where possible: clarifying expectations at work, breaking problems into steps and asking for practical support. If stress feels unmanageable or affects daily life for weeks, speaking with a doctor or mental health professional is a sensible step.</p>','When you face a threat, your body releases adrenaline and cortisol. Heart rate and breathing speed up, muscles tense and energy is redirected from digestion to readiness. This fight-or-flight response is helpful for short emergencies, such as stepping back from a speeding car.
Problems arise when stressors are constant, such as work pressure, money worries or caring responsibilities. The stress system stays partially activated, and its effects accumulate: disturbed sleep, headaches, muscle tension, digestive problems, irritability and difficulty concentrating are common. Over time, chronic stress is associated with higher blood pressure and a greater risk of anxiety and depression.
What helps the body reset
Physical activity uses up stress hormones and improves mood. Slow breathing, with longer exhalations than inhalations, activates the parasympathetic nervous system, which calms the body. Regular sleep, time outdoors and social connection all act as buffers.
Changing the source
Techniques help, but so does addressing the cause where possible: clarifying expectations at work, breaking problems into steps and asking for practical support. If stress feels unmanageable or affects daily life for weeks, speaking with a doctor or mental health professional is a sensible step.',3,8,'/media/covers/what-stress-does-to-the-body.svg','published','2026-07-17 14:12:40.563957','2026-07-14 14:12:40.563957','2026-10-31 07:12:40.756146',859);
INSERT INTO "documents" VALUES(27,'Passkeys explained: how they replace passwords','passkeys-explained-how-they-replace-passwords','Passkeys let you sign in with your fingerprint, face or device PIN instead of a password. Here is what happens behind the scenes and why they resist phishing.','<p>A passkey is a pair of cryptographic keys created for one website or app. The public key is stored by the service, while the private key never leaves your device or your password manager. When you sign in, the service sends a challenge, your device signs it with the private key, and the service checks the signature with the public key.</p>
<p>You unlock the private key with whatever you already use to unlock your phone or laptop: a fingerprint, your face or a PIN. That local check is not sent to the website. The site only learns that a valid signature arrived.</p>
<h2>Why passkeys stop phishing</h2>
<p>A password can be typed into a fake login page. A passkey cannot, because it is bound to the real domain name. If a copycat site asks for a signature, your device simply has no passkey for that address.</p>
<p>There is also nothing useful to steal from the server. A database of public keys does not let an attacker sign in anywhere.</p>
<h2>What to keep in mind</h2>
<p>Passkeys sync through your platform account or password manager, so protect that account well and keep a recovery method up to date. Many sites still keep a password as a fallback during the transition, which means the old weak point remains until you remove it.</p>','A passkey is a pair of cryptographic keys created for one website or app. The public key is stored by the service, while the private key never leaves your device or your password manager. When you sign in, the service sends a challenge, your device signs it with the private key, and the service checks the signature with the public key.
You unlock the private key with whatever you already use to unlock your phone or laptop: a fingerprint, your face or a PIN. That local check is not sent to the website. The site only learns that a valid signature arrived.
Why passkeys stop phishing
A password can be typed into a fake login page. A passkey cannot, because it is bound to the real domain name. If a copycat site asks for a signature, your device simply has no passkey for that address.
There is also nothing useful to steal from the server. A database of public keys does not let an attacker sign in anywhere.
What to keep in mind
Passkeys sync through your platform account or password manager, so protect that account well and keep a recovery method up to date. Many sites still keep a password as a fallback during the transition, which means the old weak point remains until you remove it.',1,6,'/media/covers/passkeys-explained-how-they-replace-passwords.svg','published','2026-07-20 13:12:40.563957','2026-07-16 13:12:40.563957','2026-10-31 07:12:40.756146',1072);
INSERT INTO "documents" VALUES(28,'Index funds: why many investors keep it simple','index-funds-why-many-investors-keep-it-simple','Index funds hold all the companies in a market index instead of trying to pick winners. Low costs and broad diversification explain their popularity.','<p>A market index tracks the performance of a group of investments, such as the largest companies listed in a country. An index fund simply buys all, or a representative sample, of the holdings in that index. Instead of trying to beat the market, it aims to match it.</p>
<p>Actively managed funds employ analysts to select investments they expect to outperform. Some succeed in a given year, but research has repeatedly found that, after fees, most active funds underperform their benchmark index over long periods, and it is hard to identify the winners in advance.</p>
<h2>Why costs matter</h2>
<p>Because index funds do not need large research teams and trade less often, their fees are typically much lower. A difference of one percentage point a year may sound small, but compounded over decades it can consume a large share of returns.</p>
<h2>Things to understand</h2>
<p>Index funds still rise and fall with the market, sometimes sharply, so they suit long time horizons. Diversifying across regions and asset types, rebalancing occasionally and avoiding panic selling during downturns are as important as the choice of fund. This article is general information, not investment advice; consider your own situation or speak with a licensed adviser.</p>','A market index tracks the performance of a group of investments, such as the largest companies listed in a country. An index fund simply buys all, or a representative sample, of the holdings in that index. Instead of trying to beat the market, it aims to match it.
Actively managed funds employ analysts to select investments they expect to outperform. Some succeed in a given year, but research has repeatedly found that, after fees, most active funds underperform their benchmark index over long periods, and it is hard to identify the winners in advance.
Why costs matter
Because index funds do not need large research teams and trade less often, their fees are typically much lower. A difference of one percentage point a year may sound small, but compounded over decades it can consume a large share of returns.
Things to understand
Index funds still rise and fall with the market, sometimes sharply, so they suit long time horizons. Diversifying across regions and asset types, rebalancing occasionally and avoiding panic selling during downturns are as important as the choice of fund. This article is general information, not investment advice; consider your own situation or speak with a licensed adviser.',5,9,'/media/covers/index-funds-why-many-investors-keep-it-simple.svg','published','2026-07-23 13:12:40.563957','2026-07-19 13:12:40.563957','2026-10-31 07:12:40.756146',1253);
INSERT INTO "documents" VALUES(29,'Hand washing: the simplest public health tool','hand-washing-the-simplest-public-health-tool','Washing hands with soap for about 20 seconds removes germs that spread colds, stomach bugs and more. Technique matters more than people think.','<p>Hands pick up germs from surfaces, food and other people, then carry them to our eyes, nose and mouth. Regular hand washing is one of the most effective ways to prevent the spread of respiratory and gastrointestinal infections, both at home and in hospitals.</p>
<p>Soap works in two ways. Its molecules have one end that attracts water and another that attracts fats, so it lifts oils and dirt, with the microbes they contain, off the skin. It also breaks apart the fatty outer layer of many viruses. Rinsing then carries everything away.</p>
<h2>Doing it properly</h2>
<p>Wet your hands, apply soap and rub all surfaces, including the backs of hands, between fingers, thumbs and under nails, for about 20 seconds. Rinse under running water and dry with a clean towel or air dryer. The key moments are before eating or preparing food, after using the toilet, after blowing your nose and after caring for someone who is ill.</p>
<h2>What about sanitiser?</h2>
<p>Alcohol-based hand sanitiser with at least 60 percent alcohol is a good option when soap and water are unavailable. It is less effective on visibly dirty or greasy hands and against some germs, so washing remains the first choice.</p>','Hands pick up germs from surfaces, food and other people, then carry them to our eyes, nose and mouth. Regular hand washing is one of the most effective ways to prevent the spread of respiratory and gastrointestinal infections, both at home and in hospitals.
Soap works in two ways. Its molecules have one end that attracts water and another that attracts fats, so it lifts oils and dirt, with the microbes they contain, off the skin. It also breaks apart the fatty outer layer of many viruses. Rinsing then carries everything away.
Doing it properly
Wet your hands, apply soap and rub all surfaces, including the backs of hands, between fingers, thumbs and under nails, for about 20 seconds. Rinse under running water and dry with a clean towel or air dryer. The key moments are before eating or preparing food, after using the toilet, after blowing your nose and after caring for someone who is ill.
What about sanitiser?
Alcohol-based hand sanitiser with at least 60 percent alcohol is a good option when soap and water are unavailable. It is less effective on visibly dirty or greasy hands and against some germs, so washing remains the first choice.',3,9,'/media/covers/hand-washing-the-simplest-public-health-tool.svg','published','2026-07-26 20:12:40.563957','2026-07-24 20:12:40.563957','2026-10-31 07:12:40.756146',201);
INSERT INTO "documents" VALUES(30,'How to read a scientific paper','how-to-read-a-scientific-paper','Research papers follow a predictable structure. Reading them in a strategic order, rather than front to back, saves time and improves understanding.','<p>Scientific papers can feel dense, but most follow a common structure: abstract, introduction, methods, results, discussion and references. Knowing what each part does lets you read strategically instead of struggling through every sentence in order.</p>
<p>Start with the abstract to understand the question and main finding. Then read the introduction to see why the question matters, and jump to the figures and tables, which often contain the core evidence. Read the discussion to see how the authors interpret their results and what limitations they acknowledge. Read the methods in detail only when you need to judge how reliable the study is.</p>
<h2>Questions to ask</h2>
<p>What exactly was measured, and in whom or what? How large was the sample? Was there a control group? Do the results support the strength of the conclusions, or do the authors go beyond their data? Who funded the research, and are there conflicts of interest?</p>
<h2>Context is everything</h2>
<p>A single paper is rarely the final word. Look for review articles that summarise many studies, check whether results have been replicated and note whether the paper has been peer reviewed or is a preprint. Keeping short notes on each paper you read makes it much easier to connect ideas later.</p>','Scientific papers can feel dense, but most follow a common structure: abstract, introduction, methods, results, discussion and references. Knowing what each part does lets you read strategically instead of struggling through every sentence in order.
Start with the abstract to understand the question and main finding. Then read the introduction to see why the question matters, and jump to the figures and tables, which often contain the core evidence. Read the discussion to see how the authors interpret their results and what limitations they acknowledge. Read the methods in detail only when you need to judge how reliable the study is.
Questions to ask
What exactly was measured, and in whom or what? How large was the sample? Was there a control group? Do the results support the strength of the conclusions, or do the authors go beyond their data? Who funded the research, and are there conflicts of interest?
Context is everything
A single paper is rarely the final word. Look for review articles that summarise many studies, check whether results have been replicated and note whether the paper has been peer reviewed or is a preprint. Keeping short notes on each paper you read makes it much easier to connect ideas later.',6,7,'/media/covers/how-to-read-a-scientific-paper.svg','published','2026-07-30 03:12:40.563957','2026-07-26 03:12:40.563957','2026-10-31 07:12:40.756146',498);
INSERT INTO "documents" VALUES(31,'How GPS knows where you are, relativity included','how-gps-knows-where-you-are-relativity-included','Your phone finds its position by timing signals from satellites. The clocks are so precise that Einstein''s theories have to be built into the system.','<p>The Global Positioning System is a constellation of satellites orbiting about 20,000 kilometres above Earth. Each satellite carries atomic clocks and continuously broadcasts its position and the exact time the signal was sent.</p>
<p>Your receiver measures when each signal arrives. Because radio waves travel at the speed of light, the delay tells it how far away each satellite is. With distances to at least four satellites, the receiver can solve for its latitude, longitude, altitude and the error in its own, much cheaper, clock.</p>
<h2>Where relativity comes in</h2>
<p>Timing errors matter enormously: a billionth of a second corresponds to about 30 centimetres. Special relativity says the fast-moving satellite clocks tick slightly slower than clocks on the ground. General relativity says clocks higher up in a weaker gravitational field tick slightly faster. The combined effect is that satellite clocks would gain roughly 38 microseconds per day. Left uncorrected, positions would drift by kilometres within a day, so the clocks are adjusted to compensate.</p>
<h2>Beyond GPS</h2>
<p>Phones also use other satellite systems, nearby Wi-Fi networks and motion sensors, which speeds up the first fix and improves accuracy in cities where tall buildings block the sky.</p>','The Global Positioning System is a constellation of satellites orbiting about 20,000 kilometres above Earth. Each satellite carries atomic clocks and continuously broadcasts its position and the exact time the signal was sent.
Your receiver measures when each signal arrives. Because radio waves travel at the speed of light, the delay tells it how far away each satellite is. With distances to at least four satellites, the receiver can solve for its latitude, longitude, altitude and the error in its own, much cheaper, clock.
Where relativity comes in
Timing errors matter enormously: a billionth of a second corresponds to about 30 centimetres. Special relativity says the fast-moving satellite clocks tick slightly slower than clocks on the ground. General relativity says clocks higher up in a weaker gravitational field tick slightly faster. The combined effect is that satellite clocks would gain roughly 38 microseconds per day. Left uncorrected, positions would drift by kilometres within a day, so the clocks are adjusted to compensate.
Beyond GPS
Phones also use other satellite systems, nearby Wi-Fi networks and motion sensors, which speeds up the first fix and improves accuracy in cities where tall buildings block the sky.',2,8,'/media/covers/how-gps-knows-where-you-are-relativity-included.svg','published','2026-08-02 05:12:40.563957','2026-08-01 05:12:40.563957','2026-10-31 07:12:40.756146',513);
INSERT INTO "documents" VALUES(32,'How antibiotics work, and why resistance is rising','how-antibiotics-work-and-why-resistance-is-rising','Antibiotics kill bacteria or stop them multiplying, but every use gives resistant strains an advantage. Why finishing the right course, and skipping unnecessary ones, matters.','<p>Antibiotics are medicines that target features bacteria have but human cells do not. Some, such as penicillin, weaken the bacterial cell wall until it bursts. Others block the machinery bacteria use to make proteins or copy their DNA. Antibiotics do not work against viruses, so they do not help with colds or flu.</p>
<p>Bacteria multiply quickly, and random mutations occasionally make one resistant to a drug. When antibiotics are used, susceptible bacteria die and resistant ones survive and multiply. Bacteria can also share resistance genes with each other. The more antibiotics are used, in people and in animals, the stronger this selection pressure becomes.</p>
<h2>Why it matters</h2>
<p>Resistant infections are harder to treat, require stronger drugs with more side effects and can be life-threatening. Routine procedures such as surgery, chemotherapy and caesarean sections rely on effective antibiotics to prevent infections.</p>
<h2>What individuals can do</h2>
<p>Take antibiotics only when prescribed, follow the instructions about dose and duration, never share them and do not save leftovers for later. Vaccination and good hygiene reduce infections in the first place, which reduces the need for antibiotics at all.</p>','Antibiotics are medicines that target features bacteria have but human cells do not. Some, such as penicillin, weaken the bacterial cell wall until it bursts. Others block the machinery bacteria use to make proteins or copy their DNA. Antibiotics do not work against viruses, so they do not help with colds or flu.
Bacteria multiply quickly, and random mutations occasionally make one resistant to a drug. When antibiotics are used, susceptible bacteria die and resistant ones survive and multiply. Bacteria can also share resistance genes with each other. The more antibiotics are used, in people and in animals, the stronger this selection pressure becomes.
Why it matters
Resistant infections are harder to treat, require stronger drugs with more side effects and can be life-threatening. Routine procedures such as surgery, chemotherapy and caesarean sections rely on effective antibiotics to prevent infections.
What individuals can do
Take antibiotics only when prescribed, follow the instructions about dose and duration, never share them and do not save leftovers for later. Vaccination and good hygiene reduce infections in the first place, which reduces the need for antibiotics at all.',3,8,'/media/covers/how-antibiotics-work-and-why-resistance-is-rising.svg','published','2026-08-05 04:12:40.563957','2026-08-03 04:12:40.563957','2026-10-31 07:12:40.756146',342);
INSERT INTO "documents" VALUES(33,'Electric cars: how lifetime emissions compare','electric-cars-how-lifetime-emissions-compare','Building an electric car''s battery creates extra emissions at the start, but lower emissions on the road usually make up for it over the vehicle''s life.','<p>Comparing electric and petrol cars fairly means looking at their whole life cycle: making the vehicle, producing the fuel or electricity, driving it and eventually recycling or disposing of it. This is called a life-cycle assessment.</p>
<p>Manufacturing an electric car usually produces more emissions than manufacturing a similar petrol car, mainly because battery production is energy-intensive. On the road, however, an electric car has no tailpipe emissions, and the emissions from generating its electricity are typically much lower than those from burning petrol or diesel.</p>
<h2>The break-even point</h2>
<p>After a certain distance, the electric car&#x27;s lower running emissions outweigh its higher manufacturing emissions. Studies in many regions find that, over a typical lifetime, battery electric cars produce substantially less greenhouse gas than comparable combustion cars. The advantage is greatest where electricity comes mostly from renewables or nuclear power and smaller where it relies heavily on coal.</p>
<h2>Getting the most benefit</h2>
<p>Smaller vehicles with modest battery sizes have lower manufacturing footprints. Charging when renewable output is high, keeping cars in use for longer and recycling batteries all improve the picture further. Of course, walking, cycling and public transport remain lower-impact options still.</p>','Comparing electric and petrol cars fairly means looking at their whole life cycle: making the vehicle, producing the fuel or electricity, driving it and eventually recycling or disposing of it. This is called a life-cycle assessment.
Manufacturing an electric car usually produces more emissions than manufacturing a similar petrol car, mainly because battery production is energy-intensive. On the road, however, an electric car has no tailpipe emissions, and the emissions from generating its electricity are typically much lower than those from burning petrol or diesel.
The break-even point
After a certain distance, the electric car''s lower running emissions outweigh its higher manufacturing emissions. Studies in many regions find that, over a typical lifetime, battery electric cars produce substantially less greenhouse gas than comparable combustion cars. The advantage is greatest where electricity comes mostly from renewables or nuclear power and smaller where it relies heavily on coal.
Getting the most benefit
Smaller vehicles with modest battery sizes have lower manufacturing footprints. Charging when renewable output is high, keeping cars in use for longer and recycling batteries all improve the picture further. Of course, walking, cycling and public transport remain lower-impact options still.',4,6,'/media/covers/electric-cars-how-lifetime-emissions-compare.svg','published','2026-08-07 11:12:40.563957','2026-08-05 11:12:40.563957','2026-10-31 07:12:40.756146',281);
INSERT INTO "documents" VALUES(34,'Screens and your eyes: what the evidence says','screens-and-your-eyes-what-the-evidence-says','Hours of screen use can leave eyes tired and dry, but simple habits like the 20-20-20 rule bring relief. What we know about blue light and children''s eyesight.','<p>Many people who work at screens notice tired, dry or irritated eyes, blurred vision and headaches by the end of the day. Eye care professionals call this digital eye strain. One reason is that we blink much less often while concentrating on a screen, so the surface of the eye dries out. Focusing at a fixed distance for long periods also tires the eye muscles.</p>
<p>A simple habit helps: the 20-20-20 rule. Every 20 minutes, look at something about 20 feet, or six metres, away for 20 seconds. Position the screen slightly below eye level and about an arm&#x27;s length away, reduce glare and match screen brightness to the room.</p>
<h2>The blue light question</h2>
<p>Screens emit blue light, but far less than daylight. Current evidence does not show that screen blue light damages the eyes, and blue-light-filtering glasses have not been shown to reduce eye strain. Bright screens late at night can, however, make it harder to fall asleep.</p>
<h2>Children and short-sightedness</h2>
<p>Short-sightedness is becoming more common in children worldwide. Research suggests that time spent outdoors in daylight is protective, so balancing indoor screen time with outdoor play is a sensible goal.</p>','Many people who work at screens notice tired, dry or irritated eyes, blurred vision and headaches by the end of the day. Eye care professionals call this digital eye strain. One reason is that we blink much less often while concentrating on a screen, so the surface of the eye dries out. Focusing at a fixed distance for long periods also tires the eye muscles.
A simple habit helps: the 20-20-20 rule. Every 20 minutes, look at something about 20 feet, or six metres, away for 20 seconds. Position the screen slightly below eye level and about an arm''s length away, reduce glare and match screen brightness to the room.
The blue light question
Screens emit blue light, but far less than daylight. Current evidence does not show that screen blue light damages the eyes, and blue-light-filtering glasses have not been shown to reduce eye strain. Bright screens late at night can, however, make it harder to fall asleep.
Children and short-sightedness
Short-sightedness is becoming more common in children worldwide. Research suggests that time spent outdoors in daylight is protective, so balancing indoor screen time with outdoor play is a sensible goal.',3,6,'/media/covers/screens-and-your-eyes-what-the-evidence-says.svg','published','2026-08-10 18:12:40.563957','2026-08-09 18:12:40.563957','2026-10-31 07:12:40.756146',232);
INSERT INTO "documents" VALUES(35,'How central banks use interest rates','how-central-banks-use-interest-rates','Central banks raise or lower a key interest rate to steer inflation and employment. The effects ripple through loans, savings, currencies and asset prices.','<p>Most central banks have a mandate to keep inflation low and stable, and some are also asked to support employment. Their main tool is a policy interest rate, the rate at which they lend to or pay commercial banks. Changes to it influence the rates banks charge households and businesses.</p>
<p>When inflation is too high, a central bank may raise rates. Borrowing becomes more expensive, so people and companies spend and invest less, saving becomes more attractive and demand cools, which eventually eases price pressures. When the economy is weak and inflation is low, cutting rates does the opposite and encourages spending.</p>
<h2>Delays and side effects</h2>
<p>Interest rate changes take time to work through the economy, often a year or more. Central banks therefore act on forecasts, which makes their decisions difficult and sometimes controversial. Higher rates can also strengthen a currency, lower the price of bonds and other assets, and increase pressure on borrowers with variable-rate loans.</p>
<h2>Other tools</h2>
<p>When rates are already very low, central banks have bought government bonds and other assets to lower long-term interest rates, a policy known as quantitative easing. They also use public communication, called forward guidance, to shape expectations about future policy.</p>','Most central banks have a mandate to keep inflation low and stable, and some are also asked to support employment. Their main tool is a policy interest rate, the rate at which they lend to or pay commercial banks. Changes to it influence the rates banks charge households and businesses.
When inflation is too high, a central bank may raise rates. Borrowing becomes more expensive, so people and companies spend and invest less, saving becomes more attractive and demand cools, which eventually eases price pressures. When the economy is weak and inflation is low, cutting rates does the opposite and encourages spending.
Delays and side effects
Interest rate changes take time to work through the economy, often a year or more. Central banks therefore act on forecasts, which makes their decisions difficult and sometimes controversial. Higher rates can also strengthen a currency, lower the price of bonds and other assets, and increase pressure on borrowers with variable-rate loans.
Other tools
When rates are already very low, central banks have bought government bonds and other assets to lower long-term interest rates, a policy known as quantitative easing. They also use public communication, called forward guidance, to shape expectations about future policy.',5,9,'/media/covers/how-central-banks-use-interest-rates.svg','published','2026-08-13 19:12:40.563957','2026-08-09 19:12:40.563957','2026-10-31 07:12:40.756146',788);
INSERT INTO "documents" VALUES(36,'Black holes without the jargon','black-holes-without-the-jargon','A black hole is a region where gravity is so strong that not even light can escape. Here is how they form and how astronomers study something invisible.','<p>Gravity depends on how much mass is packed into how small a space. Squeeze enough mass into a small enough region and the escape speed exceeds the speed of light. The boundary where that happens is the event horizon. Nothing that crosses it, not even light, can come back out.</p>
<p>Stellar black holes form when very massive stars run out of fuel. The core can no longer support itself and collapses, often while the outer layers explode as a supernova. Supermassive black holes, millions or billions of times the mass of the Sun, sit at the centres of most large galaxies, including our own Milky Way.</p>
<h2>Seeing the invisible</h2>
<p>Astronomers detect black holes by their effects. Gas swirling towards them heats up and glows brightly in X-rays. Stars near the centre of our galaxy move in tight, fast orbits around an unseen mass. When two black holes merge, they send out gravitational waves that detectors on Earth can measure.</p>
<p>Radio telescopes linked across the planet have even produced images of the glowing ring of material around the shadow of a black hole, a result that matched the predictions of general relativity.</p>','Gravity depends on how much mass is packed into how small a space. Squeeze enough mass into a small enough region and the escape speed exceeds the speed of light. The boundary where that happens is the event horizon. Nothing that crosses it, not even light, can come back out.
Stellar black holes form when very massive stars run out of fuel. The core can no longer support itself and collapses, often while the outer layers explode as a supernova. Supermassive black holes, millions or billions of times the mass of the Sun, sit at the centres of most large galaxies, including our own Milky Way.
Seeing the invisible
Astronomers detect black holes by their effects. Gas swirling towards them heats up and glows brightly in X-rays. Stars near the centre of our galaxy move in tight, fast orbits around an unseen mass. When two black holes merge, they send out gravitational waves that detectors on Earth can measure.
Radio telescopes linked across the planet have even produced images of the glowing ring of material around the shadow of a black hole, a result that matched the predictions of general relativity.',2,7,'/media/covers/black-holes-without-the-jargon.svg','published','2026-08-16 12:12:40.563957','2026-08-12 12:12:40.563957','2026-10-31 07:12:40.756146',76);
INSERT INTO "documents" VALUES(37,'How urban trees cool our cities','how-urban-trees-cool-our-cities','Cities can be several degrees hotter than the surrounding countryside. Trees provide shade and evaporative cooling, making streets more comfortable and healthier.','<p>Dense cities often feel hotter than nearby rural areas, especially at night. Asphalt, concrete and brick absorb sunlight during the day and release the heat slowly, while vehicles, air conditioners and industry add more. This is known as the urban heat island effect.</p>
<p>Trees counter it in two main ways. Their canopies shade pavements, walls and people, so surfaces stay much cooler than those in direct sun. Trees also release water vapour through their leaves, a process called transpiration, which cools the surrounding air in a similar way to sweat cooling skin.</p>
<h2>Benefits beyond temperature</h2>
<p>Cooler streets reduce heat-related illness during heatwaves, particularly for older people and those without air conditioning. Trees also capture rainwater, reduce flooding, filter some air pollution, provide habitat for birds and insects and make neighbourhoods more pleasant for walking.</p>
<h2>Planting for the future</h2>
<p>Tree cover in many cities is uneven, with less shade in poorer neighbourhoods. Effective planting programmes choose species suited to future climate conditions, give roots enough space and water, and commit to maintenance, because young trees need years of care before they deliver their full benefits.</p>','Dense cities often feel hotter than nearby rural areas, especially at night. Asphalt, concrete and brick absorb sunlight during the day and release the heat slowly, while vehicles, air conditioners and industry add more. This is known as the urban heat island effect.
Trees counter it in two main ways. Their canopies shade pavements, walls and people, so surfaces stay much cooler than those in direct sun. Trees also release water vapour through their leaves, a process called transpiration, which cools the surrounding air in a similar way to sweat cooling skin.
Benefits beyond temperature
Cooler streets reduce heat-related illness during heatwaves, particularly for older people and those without air conditioning. Trees also capture rainwater, reduce flooding, filter some air pollution, provide habitat for birds and insects and make neighbourhoods more pleasant for walking.
Planting for the future
Tree cover in many cities is uneven, with less shade in poorer neighbourhoods. Effective planting programmes choose species suited to future climate conditions, give roots enough space and water, and commit to maintenance, because young trees need years of care before they deliver their full benefits.',4,6,'/media/covers/how-urban-trees-cool-our-cities.svg','published','2026-08-19 15:12:40.563957','2026-08-16 15:12:40.563957','2026-10-31 07:12:40.756146',129);
INSERT INTO "documents" VALUES(38,'How to build an emergency fund','how-to-build-an-emergency-fund','An emergency fund turns a crisis into an inconvenience. How much to aim for, where to keep it and how to build it without feeling deprived.','<p>An emergency fund is money set aside for unexpected costs such as a car repair, a medical bill or a period without income. Without one, these surprises often end up on a credit card or a high-interest loan, which turns a short-term problem into a long-term one.</p>
<p>A common guideline is to save enough to cover three to six months of essential expenses: housing, food, utilities, transport and minimum debt payments. People with irregular income, dependants or a single household income may want more. If that target feels overwhelming, start with a smaller first goal, such as one month of essentials.</p>
<h2>Where to keep it</h2>
<p>The fund should be safe and easy to access, but not so easy that it gets spent on everyday purchases. A separate savings account, ideally one that pays competitive interest, works well for many people. Investing emergency money in assets that can fall sharply in value defeats the purpose.</p>
<h2>Building it steadily</h2>
<p>Automate a transfer on payday so saving happens before spending. Direct windfalls, such as tax refunds or bonuses, towards the fund. Once you use it, rebuild it before returning to other goals. This is general information rather than personal financial advice.</p>','An emergency fund is money set aside for unexpected costs such as a car repair, a medical bill or a period without income. Without one, these surprises often end up on a credit card or a high-interest loan, which turns a short-term problem into a long-term one.
A common guideline is to save enough to cover three to six months of essential expenses: housing, food, utilities, transport and minimum debt payments. People with irregular income, dependants or a single household income may want more. If that target feels overwhelming, start with a smaller first goal, such as one month of essentials.
Where to keep it
The fund should be safe and easy to access, but not so easy that it gets spent on everyday purchases. A separate savings account, ideally one that pays competitive interest, works well for many people. Investing emergency money in assets that can fall sharply in value defeats the purpose.
Building it steadily
Automate a transfer on payday so saving happens before spending. Direct windfalls, such as tax refunds or bonuses, towards the fund. Once you use it, rebuild it before returning to other goals. This is general information rather than personal financial advice.',5,6,'/media/covers/how-to-build-an-emergency-fund.svg','published','2026-08-22 14:12:40.563957','2026-08-21 14:12:40.563957','2026-10-31 07:12:40.756146',151);
INSERT INTO "documents" VALUES(39,'What really happens to your recycling','what-really-happens-to-your-recycling','Your recycling bin is the first step in a long sorting process. Contamination and mixed materials are the main reasons items end up wasted.','<p>After collection, mixed recycling goes to a materials recovery facility. Conveyor belts, screens, magnets, air jets and optical scanners separate paper, cardboard, metals and different types of plastic, while workers remove items that should not be there. The sorted materials are baled and sold to manufacturers who turn them into new products.</p>
<p>Metals such as aluminium and steel can be recycled repeatedly with little loss of quality, which makes cans especially valuable. Paper fibres shorten each time they are recycled, so paper can only go round a limited number of times. Plastics are the most complicated: there are many types, and only some, such as bottles made of PET and HDPE, have reliable markets in many places.</p>
<h2>The contamination problem</h2>
<p>Food residue, liquids and non-recyclable items can spoil whole batches. Plastic bags and film often jam sorting machines. Rinsing containers quickly, keeping recyclables loose rather than bagged, and checking local rules make a real difference.</p>
<h2>Recycling is the last resort</h2>
<p>Recycling saves energy and raw materials, but reducing and reusing save more. Choosing durable products, refilling containers and avoiding unnecessary packaging prevents waste before it needs sorting.</p>','After collection, mixed recycling goes to a materials recovery facility. Conveyor belts, screens, magnets, air jets and optical scanners separate paper, cardboard, metals and different types of plastic, while workers remove items that should not be there. The sorted materials are baled and sold to manufacturers who turn them into new products.
Metals such as aluminium and steel can be recycled repeatedly with little loss of quality, which makes cans especially valuable. Paper fibres shorten each time they are recycled, so paper can only go round a limited number of times. Plastics are the most complicated: there are many types, and only some, such as bottles made of PET and HDPE, have reliable markets in many places.
The contamination problem
Food residue, liquids and non-recyclable items can spoil whole batches. Plastic bags and film often jam sorting machines. Rinsing containers quickly, keeping recyclables loose rather than bagged, and checking local rules make a real difference.
Recycling is the last resort
Recycling saves energy and raw materials, but reducing and reusing save more. Choosing durable products, refilling containers and avoiding unnecessary packaging prevents waste before it needs sorting.',4,8,'/media/covers/what-really-happens-to-your-recycling.svg','published','2026-08-26 04:12:40.563957','2026-08-23 04:12:40.563957','2026-10-31 07:12:40.756146',795);
INSERT INTO "documents" VALUES(40,'Learning a language as an adult','learning-a-language-as-an-adult','Children are not the only ones who can learn languages. Adults bring advantages of their own, and the right habits make steady progress possible.','<p>It is often said that children learn languages effortlessly while adults struggle. Children do have advantages, especially with pronunciation when they start young and are surrounded by the language. But adults also have strengths: they can understand grammar explanations, use learning strategies deliberately and relate new words to knowledge they already have.</p>
<p>The most important factor for most learners is the amount of meaningful input they receive. Listening to and reading material you mostly understand, such as podcasts, graded readers, videos with subtitles or simple news, builds vocabulary and an intuitive feel for the language.</p>
<h2>Speaking and practice</h2>
<p>Speaking early, even imperfectly, helps. Conversation partners, tutors and language exchanges give practice and feedback. Mistakes are part of the process, not a sign of failure.</p>
<h2>Consistency over intensity</h2>
<p>Short daily practice is more effective than occasional long sessions. Spaced repetition apps help with vocabulary, while setting concrete goals, such as ordering a meal or holding a ten-minute conversation, keeps motivation high. Choosing content that genuinely interests you, such as cooking, sport or music, turns study into something you look forward to.</p>','It is often said that children learn languages effortlessly while adults struggle. Children do have advantages, especially with pronunciation when they start young and are surrounded by the language. But adults also have strengths: they can understand grammar explanations, use learning strategies deliberately and relate new words to knowledge they already have.
The most important factor for most learners is the amount of meaningful input they receive. Listening to and reading material you mostly understand, such as podcasts, graded readers, videos with subtitles or simple news, builds vocabulary and an intuitive feel for the language.
Speaking and practice
Speaking early, even imperfectly, helps. Conversation partners, tutors and language exchanges give practice and feedback. Mistakes are part of the process, not a sign of failure.
Consistency over intensity
Short daily practice is more effective than occasional long sessions. Spaced repetition apps help with vocabulary, while setting concrete goals, such as ordering a meal or holding a ten-minute conversation, keeps motivation high. Choosing content that genuinely interests you, such as cooking, sport or music, turns study into something you look forward to.',6,8,'/media/covers/learning-a-language-as-an-adult.svg','published','2026-08-28 11:12:40.563957','2026-08-25 11:12:40.563957','2026-10-31 07:12:40.756146',1754);
INSERT INTO "documents" VALUES(41,'CRISPR gene editing: what it can and cannot do','crispr-gene-editing-what-it-can-and-cannot-do','CRISPR lets scientists cut DNA at chosen locations with remarkable precision. It is transforming research and starting to reach patients, but it has limits.','<p>CRISPR began as part of a bacterial immune system. Bacteria store snippets of viral DNA and use them to guide an enzyme, most famously Cas9, to cut matching viral genes. Researchers realised the system could be reprogrammed: supply a short guide RNA that matches any DNA sequence, and the enzyme will cut there.</p>
<p>After the cut, the cell repairs its DNA. Sometimes the repair disables the gene, which is useful for studying what a gene does. With a template provided, the repair can also insert or correct a sequence. Newer variants, such as base editors and prime editors, change individual letters of DNA without making a full double-strand cut.</p>
<h2>From the lab to patients</h2>
<p>CRISPR is now a standard laboratory tool for studying genes in cells, plants and animals. The first therapies approved for patients edit a person&#x27;s own blood stem cells outside the body to treat certain inherited blood disorders.</p>
<h2>Limits and open questions</h2>
<p>Delivering editors to the right cells inside the body remains difficult. Unintended edits elsewhere in the genome must be carefully measured. Editing embryos, where changes would be inherited, raises ethical concerns that most countries currently address with strict limits or bans.</p>','CRISPR began as part of a bacterial immune system. Bacteria store snippets of viral DNA and use them to guide an enzyme, most famously Cas9, to cut matching viral genes. Researchers realised the system could be reprogrammed: supply a short guide RNA that matches any DNA sequence, and the enzyme will cut there.
After the cut, the cell repairs its DNA. Sometimes the repair disables the gene, which is useful for studying what a gene does. With a template provided, the repair can also insert or correct a sequence. Newer variants, such as base editors and prime editors, change individual letters of DNA without making a full double-strand cut.
From the lab to patients
CRISPR is now a standard laboratory tool for studying genes in cells, plants and animals. The first therapies approved for patients edit a person''s own blood stem cells outside the body to treat certain inherited blood disorders.
Limits and open questions
Delivering editors to the right cells inside the body remains difficult. Unintended edits elsewhere in the genome must be carefully measured. Editing embryos, where changes would be inherited, raises ethical concerns that most countries currently address with strict limits or bans.',2,6,'/media/covers/crispr-gene-editing-what-it-can-and-cannot-do.svg','published','2026-09-01 04:12:40.563957','2026-08-29 04:12:40.563957','2026-10-31 07:12:40.756146',131);
INSERT INTO "documents" VALUES(42,'Reading a company''s income statement','reading-a-company-s-income-statement','An income statement shows how much a business earned, what it spent and what was left. Learn the main lines from revenue down to net profit.','<p>An income statement, also called a profit and loss statement, summarises a company&#x27;s financial performance over a period, such as a quarter or a year. It starts with revenue at the top and works down to profit at the bottom, which is why people speak of the top line and the bottom line.</p>
<p>Revenue is the money earned from selling goods or services. Subtracting the direct costs of producing them, called the cost of goods sold, gives gross profit. Dividing gross profit by revenue gives the gross margin, which shows how much of each sale is left to cover other costs.</p>
<h2>Operating costs and profit</h2>
<p>Next come operating expenses, such as salaries, rent, marketing and research. Gross profit minus operating expenses equals operating profit, a measure of how well the core business performs. After interest and taxes, what remains is net profit.</p>
<h2>Reading between the lines</h2>
<p>Compare figures across several periods and against similar companies rather than looking at a single year. Profit is not the same as cash: a company can report profits while running short of cash if customers pay slowly. That is why analysts read the income statement alongside the balance sheet and cash flow statement.</p>','An income statement, also called a profit and loss statement, summarises a company''s financial performance over a period, such as a quarter or a year. It starts with revenue at the top and works down to profit at the bottom, which is why people speak of the top line and the bottom line.
Revenue is the money earned from selling goods or services. Subtracting the direct costs of producing them, called the cost of goods sold, gives gross profit. Dividing gross profit by revenue gives the gross margin, which shows how much of each sale is left to cover other costs.
Operating costs and profit
Next come operating expenses, such as salaries, rent, marketing and research. Gross profit minus operating expenses equals operating profit, a measure of how well the core business performs. After interest and taxes, what remains is net profit.
Reading between the lines
Compare figures across several periods and against similar companies rather than looking at a single year. Profit is not the same as cash: a company can report profits while running short of cash if customers pay slowly. That is why analysts read the income statement alongside the balance sheet and cash flow statement.',5,6,'/media/covers/reading-a-company-s-income-statement.svg','published','2026-09-03 18:12:40.563957','2026-09-01 18:12:40.563957','2026-10-31 07:12:40.756146',1374);
INSERT INTO "documents" VALUES(43,'Why sleep matters for students','why-sleep-matters-for-students','Sleep is when the brain consolidates what you learned during the day. Pulling all-nighters before exams often undermines the very performance students want.','<p>During sleep, the brain replays and strengthens memories formed during the day. Studies show that people who sleep after learning remember more than those who stay awake for the same period. Deep sleep appears to support the consolidation of facts, while REM sleep is linked to emotional processing and creative problem solving.</p>
<p>Sleep deprivation affects attention, working memory and decision-making, all essential for learning and exam performance. An all-nighter before an exam may add study hours, but the tired brain retains and retrieves information less efficiently.</p>
<h2>Teenagers and late nights</h2>
<p>During adolescence, the body clock shifts later, so teenagers naturally feel sleepy later at night and struggle to wake early. Early school start times can conflict with this biology. Some schools that moved start times later have reported improvements in attendance and alertness.</p>
<h2>Better sleep for better studying</h2>
<p>Spread revision over weeks rather than cramming. Keep a regular sleep schedule, limit caffeine in the afternoon and evening and put screens away before bed. A short nap of 20 minutes or so can restore alertness without making it harder to sleep at night.</p>','During sleep, the brain replays and strengthens memories formed during the day. Studies show that people who sleep after learning remember more than those who stay awake for the same period. Deep sleep appears to support the consolidation of facts, while REM sleep is linked to emotional processing and creative problem solving.
Sleep deprivation affects attention, working memory and decision-making, all essential for learning and exam performance. An all-nighter before an exam may add study hours, but the tired brain retains and retrieves information less efficiently.
Teenagers and late nights
During adolescence, the body clock shifts later, so teenagers naturally feel sleepy later at night and struggle to wake early. Early school start times can conflict with this biology. Some schools that moved start times later have reported improvements in attendance and alertness.
Better sleep for better studying
Spread revision over weeks rather than cramming. Keep a regular sleep schedule, limit caffeine in the afternoon and evening and put screens away before bed. A short nap of 20 minutes or so can restore alertness without making it harder to sleep at night.',6,8,'/media/covers/why-sleep-matters-for-students.svg','published','2026-09-06 17:12:40.563957','2026-09-05 17:12:40.563957','2026-10-31 07:12:40.756146',814);
INSERT INTO "documents" VALUES(44,'Large language models, in plain words','large-language-models-in-plain-words','Chat assistants are built on models trained to predict the next piece of text. Understanding that one idea explains both their strengths and their mistakes.','<p>A large language model is a neural network trained on a very large collection of text. During training it repeatedly sees a passage with the next word hidden and adjusts billions of internal numbers so that its guess becomes more likely to be right. Text is split into tokens, which can be whole words or fragments of words.</p>
<p>After enough training, predicting the next token well requires picking up grammar, facts, styles of argument and patterns of reasoning that appear in the data. Developers then fine-tune the model on examples of helpful conversations and use human feedback to steer its behaviour.</p>
<h2>Why they sometimes make things up</h2>
<p>The model produces the most plausible continuation, not a looked-up answer. When the training data is thin or the question is unusual, a plausible-sounding but wrong statement can come out. Connecting the model to search or to a company&#x27;s own documents helps, because the answer can then be grounded in sources you can check.</p>
<h2>Using them well</h2>
<p>Give clear context, ask for sources or reasoning, and verify anything important. Treat the output as a capable first draft rather than a final authority.</p>','A large language model is a neural network trained on a very large collection of text. During training it repeatedly sees a passage with the next word hidden and adjusts billions of internal numbers so that its guess becomes more likely to be right. Text is split into tokens, which can be whole words or fragments of words.
After enough training, predicting the next token well requires picking up grammar, facts, styles of argument and patterns of reasoning that appear in the data. Developers then fine-tune the model on examples of helpful conversations and use human feedback to steer its behaviour.
Why they sometimes make things up
The model produces the most plausible continuation, not a looked-up answer. When the training data is thin or the question is unusual, a plausible-sounding but wrong statement can come out. Connecting the model to search or to a company''s own documents helps, because the answer can then be grounded in sources you can check.
Using them well
Give clear context, ask for sources or reasoning, and verify anything important. Treat the output as a capable first draft rather than a final authority.',1,8,'/media/covers/large-language-models-in-plain-words.svg','published','2026-09-09 23:12:40.563957','2026-09-07 23:12:40.563957','2026-10-31 07:12:40.756146',234);
INSERT INTO "documents" VALUES(45,'Hydration myths and facts','hydration-myths-and-facts','Do you really need eight glasses of water a day? Fluid needs vary, food counts, and thirst is a useful guide for most healthy people.','<p>The idea that everyone needs exactly eight glasses of water a day is widespread, but it is not a scientific rule. Fluid needs depend on body size, activity, climate and health. Much of our water comes from food, especially fruit, vegetables and soups, and drinks such as tea, coffee and milk count too.</p>
<p>For most healthy adults, thirst is a reliable signal, and pale yellow urine generally indicates good hydration. Older adults, young children and people who are ill may not feel thirst as strongly and need to pay more attention.</p>
<h2>When needs go up</h2>
<p>Hot weather, fever, vomiting, diarrhoea and prolonged exercise increase fluid losses. During long or intense activity, especially in heat, drinking regularly and replacing salt lost in sweat matters. For short, moderate workouts, water is usually enough; sports drinks add sugar many people do not need.</p>
<h2>Too much is possible</h2>
<p>Drinking very large amounts of water in a short time can dilute sodium in the blood, a dangerous condition called hyponatraemia. It is rare, but it has occurred in endurance events and drinking contests. The goal is steady, sensible intake rather than forcing down as much water as possible.</p>','The idea that everyone needs exactly eight glasses of water a day is widespread, but it is not a scientific rule. Fluid needs depend on body size, activity, climate and health. Much of our water comes from food, especially fruit, vegetables and soups, and drinks such as tea, coffee and milk count too.
For most healthy adults, thirst is a reliable signal, and pale yellow urine generally indicates good hydration. Older adults, young children and people who are ill may not feel thirst as strongly and need to pay more attention.
When needs go up
Hot weather, fever, vomiting, diarrhoea and prolonged exercise increase fluid losses. During long or intense activity, especially in heat, drinking regularly and replacing salt lost in sweat matters. For short, moderate workouts, water is usually enough; sports drinks add sugar many people do not need.
Too much is possible
Drinking very large amounts of water in a short time can dilute sodium in the blood, a dangerous condition called hyponatraemia. It is rare, but it has occurred in endurance events and drinking contests. The goal is steady, sensible intake rather than forcing down as much water as possible.',3,7,'/media/covers/hydration-myths-and-facts.svg','published','2026-09-12 15:12:40.563957','2026-09-11 15:12:40.563957','2026-10-31 07:12:40.756146',917);
INSERT INTO "documents" VALUES(46,'Coral reefs under pressure','coral-reefs-under-pressure','Coral reefs cover a tiny part of the ocean floor yet host a remarkable share of marine species. Warming water causes bleaching, which can kill corals if it lasts too long.','<p>Coral reefs are built by tiny animals called coral polyps, which secrete limestone skeletons that accumulate over centuries. Most reef-building corals live in partnership with microscopic algae inside their tissues. The algae provide food through photosynthesis and give corals much of their colour; the corals provide shelter and nutrients.</p>
<p>When water becomes too warm for an extended period, this partnership breaks down. Corals expel the algae and turn white, a process called bleaching. Bleached corals are not dead, but they are starving. If temperatures return to normal quickly, they can recover; if heat stress lasts too long, many die.</p>
<h2>Multiple threats</h2>
<p>Marine heatwaves linked to climate change have caused mass bleaching events on reefs around the world. Ocean acidification makes it harder for corals to build skeletons. Pollution, overfishing and damage from coastal development add further stress.</p>
<h2>Why reefs matter and what is being done</h2>
<p>Reefs support fisheries, protect coastlines from waves and attract tourism. Protecting reefs from local pressures improves their resilience, and scientists are researching heat-tolerant corals and restoration techniques. Ultimately, the long-term future of most reefs depends on limiting further ocean warming.</p>','Coral reefs are built by tiny animals called coral polyps, which secrete limestone skeletons that accumulate over centuries. Most reef-building corals live in partnership with microscopic algae inside their tissues. The algae provide food through photosynthesis and give corals much of their colour; the corals provide shelter and nutrients.
When water becomes too warm for an extended period, this partnership breaks down. Corals expel the algae and turn white, a process called bleaching. Bleached corals are not dead, but they are starving. If temperatures return to normal quickly, they can recover; if heat stress lasts too long, many die.
Multiple threats
Marine heatwaves linked to climate change have caused mass bleaching events on reefs around the world. Ocean acidification makes it harder for corals to build skeletons. Pollution, overfishing and damage from coastal development add further stress.
Why reefs matter and what is being done
Reefs support fisheries, protect coastlines from waves and attract tourism. Protecting reefs from local pressures improves their resilience, and scientists are researching heat-tolerant corals and restoration techniques. Ultimately, the long-term future of most reefs depends on limiting further ocean warming.',4,9,'/media/covers/coral-reefs-under-pressure.svg','published','2026-09-15 11:12:40.563957','2026-09-12 11:12:40.563957','2026-10-31 07:12:40.756146',807);
INSERT INTO "documents" VALUES(47,'Open-source software runs the world. Who maintains it?','open-source-software-runs-the-world-who-maintains-it','From web servers to the libraries inside your phone apps, open-source code is everywhere. Much of it depends on a small number of volunteers.','<p>Open-source software is code that anyone can read, modify and share under a licence that permits it. It powers most web servers, the Linux kernel inside Android phones, programming languages, databases and countless small libraries that applications quietly depend on.</p>
<p>A typical modern app includes hundreds of open-source packages, each of which may depend on others. That web of dependencies lets developers build quickly, but it also means a bug or vulnerability deep in the chain can affect thousands of products at once.</p>
<h2>The maintenance gap</h2>
<p>Popular projects are sometimes maintained by one or two people in their spare time. Reviewing contributions, answering issues and fixing security problems is real work, and burnout is common. Several well-known security incidents have traced back to under-resourced projects that many companies relied on without contributing back.</p>
<h2>How the picture is changing</h2>
<p>Foundations, company sponsorship programmes and paid maintainer roles have grown. Organisations increasingly track which open-source components they use and fund the critical ones. For individual developers, contributing documentation, tests or bug reports is a practical way to start, and it is also a well-recognised way to build a public portfolio.</p>','Open-source software is code that anyone can read, modify and share under a licence that permits it. It powers most web servers, the Linux kernel inside Android phones, programming languages, databases and countless small libraries that applications quietly depend on.
A typical modern app includes hundreds of open-source packages, each of which may depend on others. That web of dependencies lets developers build quickly, but it also means a bug or vulnerability deep in the chain can affect thousands of products at once.
The maintenance gap
Popular projects are sometimes maintained by one or two people in their spare time. Reviewing contributions, answering issues and fixing security problems is real work, and burnout is common. Several well-known security incidents have traced back to under-resourced projects that many companies relied on without contributing back.
How the picture is changing
Foundations, company sponsorship programmes and paid maintainer roles have grown. Organisations increasingly track which open-source components they use and fund the critical ones. For individual developers, contributing documentation, tests or bug reports is a practical way to start, and it is also a well-recognised way to build a public portfolio.',1,7,'/media/covers/open-source-software-runs-the-world-who-maintains-it.svg','published','2026-09-18 11:12:40.563957','2026-09-16 11:12:40.563957','2026-10-31 07:12:40.756146',1284);
INSERT INTO "documents" VALUES(48,'Why bees and other pollinators matter','why-bees-and-other-pollinators-matter','Many fruits, vegetables and nuts depend on animal pollinators. Habitat loss, pesticides and disease are putting pressure on bees, but gardens can help.','<p>Pollination is the transfer of pollen from one flower to another, allowing plants to produce seeds and fruit. Some plants rely on wind, but many depend on animals, especially insects. Bees are the best-known pollinators, alongside butterflies, moths, flies, beetles, birds and bats.</p>
<p>A large proportion of the world&#x27;s crop types benefit from animal pollination, including apples, almonds, coffee, tomatoes and many berries. Pollinators also sustain wild plants, which in turn feed and shelter other wildlife.</p>
<h2>Under pressure</h2>
<p>Honeybees are managed by beekeepers, but there are thousands of wild bee species, many of them solitary. Wild pollinators face several pressures at once: loss of flower-rich habitats, some pesticides, diseases and parasites, and changes in climate that can shift when flowers bloom relative to when insects are active.</p>
<h2>What helps</h2>
<p>Planting a variety of flowering plants that bloom from spring to autumn provides food through the season. Leaving some areas undisturbed, with bare soil, hollow stems or dead wood, offers nesting sites. Reducing pesticide use in gardens and supporting farming practices that keep hedgerows and wildflower margins also make a measurable difference.</p>','Pollination is the transfer of pollen from one flower to another, allowing plants to produce seeds and fruit. Some plants rely on wind, but many depend on animals, especially insects. Bees are the best-known pollinators, alongside butterflies, moths, flies, beetles, birds and bats.
A large proportion of the world''s crop types benefit from animal pollination, including apples, almonds, coffee, tomatoes and many berries. Pollinators also sustain wild plants, which in turn feed and shelter other wildlife.
Under pressure
Honeybees are managed by beekeepers, but there are thousands of wild bee species, many of them solitary. Wild pollinators face several pressures at once: loss of flower-rich habitats, some pesticides, diseases and parasites, and changes in climate that can shift when flowers bloom relative to when insects are active.
What helps
Planting a variety of flowering plants that bloom from spring to autumn provides food through the season. Leaving some areas undisturbed, with bare soil, hollow stems or dead wood, offers nesting sites. Reducing pesticide use in gardens and supporting farming practices that keep hedgerows and wildflower margins also make a measurable difference.',4,7,'/media/covers/why-bees-and-other-pollinators-matter.svg','published','2026-09-22 03:12:40.563957','2026-09-19 03:12:40.563957','2026-10-31 07:12:40.756146',190);
INSERT INTO "documents" VALUES(49,'The testing effect: why quizzes beat rereading','the-testing-effect-why-quizzes-beat-rereading','Retrieving information from memory strengthens it more than reviewing notes. Low-stakes self-testing is a simple, powerful study strategy.','<p>Many students study by rereading notes and highlighting textbooks. These methods feel productive, but research consistently shows that actively retrieving information, by answering questions or recalling material from memory, leads to better long-term retention. This is known as the testing effect or retrieval practice.</p>
<p>Each time you pull a fact or idea out of memory, you strengthen the pathways that lead to it and make it easier to retrieve next time. Testing also reveals what you do not know, so you can focus your effort where it is needed.</p>
<h2>Easy ways to use it</h2>
<p>Close the book and write down everything you remember about a topic, then check what you missed. Use practice questions, flashcards or past exam papers. Explain a concept aloud as if teaching someone else. Teachers can start lessons with a few quick questions on previous material.</p>
<h2>Keep the stakes low</h2>
<p>The benefit comes from the act of retrieval, not from grades. Frequent, low-pressure quizzes reduce anxiety and build confidence. Combining retrieval practice with spacing, meaning testing yourself on material over several weeks, gives even stronger results than either technique alone.</p>','Many students study by rereading notes and highlighting textbooks. These methods feel productive, but research consistently shows that actively retrieving information, by answering questions or recalling material from memory, leads to better long-term retention. This is known as the testing effect or retrieval practice.
Each time you pull a fact or idea out of memory, you strengthen the pathways that lead to it and make it easier to retrieve next time. Testing also reveals what you do not know, so you can focus your effort where it is needed.
Easy ways to use it
Close the book and write down everything you remember about a topic, then check what you missed. Use practice questions, flashcards or past exam papers. Explain a concept aloud as if teaching someone else. Teachers can start lessons with a few quick questions on previous material.
Keep the stakes low
The benefit comes from the act of retrieval, not from grades. Frequent, low-pressure quizzes reduce anxiety and build confidence. Combining retrieval practice with spacing, meaning testing yourself on material over several weeks, gives even stronger results than either technique alone.',6,6,'/media/covers/the-testing-effect-why-quizzes-beat-rereading.svg','published','2026-09-25 02:12:40.563957','2026-09-24 02:12:40.563957','2026-10-31 07:12:40.756146',278);
INSERT INTO "documents" VALUES(50,'What startups mean by product-market fit','what-startups-mean-by-product-market-fit','Product-market fit is the point where a product satisfies a strong market demand. Founders talk about it constantly because almost nothing else matters before it.','<p>Product-market fit describes a situation in which a product solves a real problem so well for a specific group of customers that demand starts to pull the company forward. Before it, founders push hard for every sale; after it, customers return, recommend the product to others and complain loudly if it disappears.</p>
<p>There is no single number that proves fit, but common signals include strong retention, meaning customers keep using or paying for the product over time, growth driven by word of mouth, and sales cycles that get shorter. Some teams survey users and ask how disappointed they would be if they could no longer use the product.</p>
<h2>Finding it</h2>
<p>Most startups do not find fit with their first idea. They interview potential customers, build small experiments, measure behaviour rather than opinions and change direction when evidence points elsewhere. Narrowing the target market often helps: delighting a small group completely beats mildly interesting a large one.</p>
<h2>Why it comes first</h2>
<p>Scaling marketing, hiring and spending before fit tends to burn money quickly without lasting results. Investors and experienced founders therefore recommend focusing obsessively on a narrow customer and problem until the signals are clear.</p>','Product-market fit describes a situation in which a product solves a real problem so well for a specific group of customers that demand starts to pull the company forward. Before it, founders push hard for every sale; after it, customers return, recommend the product to others and complain loudly if it disappears.
There is no single number that proves fit, but common signals include strong retention, meaning customers keep using or paying for the product over time, growth driven by word of mouth, and sales cycles that get shorter. Some teams survey users and ask how disappointed they would be if they could no longer use the product.
Finding it
Most startups do not find fit with their first idea. They interview potential customers, build small experiments, measure behaviour rather than opinions and change direction when evidence points elsewhere. Narrowing the target market often helps: delighting a small group completely beats mildly interesting a large one.
Why it comes first
Scaling marketing, hiring and spending before fit tends to burn money quickly without lasting results. Investors and experienced founders therefore recommend focusing obsessively on a narrow customer and problem until the signals are clear.',5,8,'/media/covers/what-startups-mean-by-product-market-fit.svg','published','2026-09-27 12:12:40.563957','2026-09-24 12:12:40.563957','2026-10-31 07:12:40.756146',1554);
INSERT INTO "documents" VALUES(51,'How recommendation algorithms decide what you see','how-recommendation-algorithms-decide-what-you-see','Video, shopping and music platforms rank content by predicting what you will engage with. Knowing the signals they use gives you more control.','<p>Recommendation systems start from a simple problem: there is far more content than anyone could browse, so something has to choose. Most platforms first gather a large pool of candidate items, then rank them with a model that predicts how likely you are to click, watch, buy or keep scrolling.</p>
<p>The signals come from your behaviour and from people similar to you. Watch time, likes, skips, searches, purchase history and even how long you pause on an item all feed the predictions. Collaborative filtering adds a simple idea: people who liked the same things in the past tend to like similar things in the future.</p>
<h2>Side effects</h2>
<p>Optimising for engagement can favour content that provokes strong reactions, and it can narrow what you see over time. Platforms counter this with diversity rules and quality signals, with mixed success.</p>
<h2>Steering your own feed</h2>
<p>Use the &quot;not interested&quot; and &quot;don&#x27;t recommend&quot; options; they are real signals. Clear or pause watch and search history if you want a fresh start. Following topics deliberately, rather than only reacting to what appears, also shifts what the system believes you want.</p>','Recommendation systems start from a simple problem: there is far more content than anyone could browse, so something has to choose. Most platforms first gather a large pool of candidate items, then rank them with a model that predicts how likely you are to click, watch, buy or keep scrolling.
The signals come from your behaviour and from people similar to you. Watch time, likes, skips, searches, purchase history and even how long you pause on an item all feed the predictions. Collaborative filtering adds a simple idea: people who liked the same things in the past tend to like similar things in the future.
Side effects
Optimising for engagement can favour content that provokes strong reactions, and it can narrow what you see over time. Platforms counter this with diversity rules and quality signals, with mixed success.
Steering your own feed
Use the "not interested" and "don''t recommend" options; they are real signals. Clear or pause watch and search history if you want a fresh start. Following topics deliberately, rather than only reacting to what appears, also shifts what the system believes you want.',1,8,'/media/covers/how-recommendation-algorithms-decide-what-you-see.svg','published','2026-09-30 16:12:40.563957','2026-09-29 16:12:40.563957','2026-10-31 07:12:40.756146',32);
INSERT INTO "documents" VALUES(52,'Online courses: how to actually finish one','online-courses-how-to-actually-finish-one','Many people sign up for online courses but few complete them. Treating the course like a real class, with a schedule and community, changes the odds.','<p>Online courses have made learning accessible to anyone with an internet connection, from university lectures to practical skills such as programming or design. Yet completion rates for many free, self-paced courses are low. The flexibility that makes them attractive also makes them easy to postpone indefinitely.</p>
<p>Start by choosing a course with a clear purpose. A specific goal, such as building a portfolio project or preparing for a certification, gives a reason to keep going. Check the time commitment and prerequisites honestly before you begin.</p>
<h2>Build structure</h2>
<p>Schedule fixed study sessions in your calendar as if they were classes. Short, frequent sessions work better than occasional marathons. Take notes, complete exercises rather than just watching videos and apply what you learn to a small project as soon as possible.</p>
<h2>Learn with others</h2>
<p>Discussion forums, study groups and online communities provide accountability and help when you are stuck. Telling a friend or colleague about your goal adds gentle pressure. If you fall behind, adjust the plan instead of abandoning it. Finishing one course thoroughly is more valuable than starting five.</p>','Online courses have made learning accessible to anyone with an internet connection, from university lectures to practical skills such as programming or design. Yet completion rates for many free, self-paced courses are low. The flexibility that makes them attractive also makes them easy to postpone indefinitely.
Start by choosing a course with a clear purpose. A specific goal, such as building a portfolio project or preparing for a certification, gives a reason to keep going. Check the time commitment and prerequisites honestly before you begin.
Build structure
Schedule fixed study sessions in your calendar as if they were classes. Short, frequent sessions work better than occasional marathons. Take notes, complete exercises rather than just watching videos and apply what you learn to a small project as soon as possible.
Learn with others
Discussion forums, study groups and online communities provide accountability and help when you are stuck. Telling a friend or colleague about your goal adds gentle pressure. If you fall behind, adjust the plan instead of abandoning it. Finishing one course thoroughly is more valuable than starting five.',6,7,'/media/covers/online-courses-how-to-actually-finish-one.svg','published','2026-10-04 04:12:40.563957','2026-10-01 04:12:40.563957','2026-10-31 07:12:40.756146',51);
INSERT INTO "documents" VALUES(53,'Spotting phishing messages before they spot you','spotting-phishing-messages-before-they-spot-you','Phishing relies on urgency and imitation. Learning a handful of warning signs, and one golden rule, prevents most account takeovers.','<p>Phishing messages pretend to come from someone you trust, such as a bank, a delivery company, a colleague or a streaming service, and try to get you to click a link, open an attachment or share information. They arrive by email, text message, social media and phone calls.</p>
<p>The strongest warning sign is pressure. Messages that say your account will be closed today, that a payment failed or that your manager needs gift cards urgently are designed to make you act before you think.</p>
<h2>Practical checks</h2>
<p>Look at the actual sender address and the real destination of links, not the display name. Watch for small misspellings in domain names. Be suspicious of unexpected attachments, especially archives and documents that ask you to enable macros. Legitimate organisations rarely ask for passwords or one-time codes.</p>
<h2>The golden rule</h2>
<p>Do not use the contact details in the message. If something seems urgent, open the app yourself or type the known website address, or call the number printed on your card. Report the message to your IT team or the impersonated company. Using passkeys or a password manager also helps, because they will not fill in credentials on a fake site.</p>','Phishing messages pretend to come from someone you trust, such as a bank, a delivery company, a colleague or a streaming service, and try to get you to click a link, open an attachment or share information. They arrive by email, text message, social media and phone calls.
The strongest warning sign is pressure. Messages that say your account will be closed today, that a payment failed or that your manager needs gift cards urgently are designed to make you act before you think.
Practical checks
Look at the actual sender address and the real destination of links, not the display name. Watch for small misspellings in domain names. Be suspicious of unexpected attachments, especially archives and documents that ask you to enable macros. Legitimate organisations rarely ask for passwords or one-time codes.
The golden rule
Do not use the contact details in the message. If something seems urgent, open the app yourself or type the known website address, or call the number printed on your card. Report the message to your IT team or the impersonated company. Using passkeys or a password manager also helps, because they will not fill in credentials on a fake site.',1,6,'/media/covers/spotting-phishing-messages-before-they-spot-you.svg','published','2026-10-06 22:12:40.563957','2026-10-04 22:12:40.563957','2026-10-31 07:12:40.756146',88);
INSERT INTO "documents" VALUES(54,'How scientists date ancient objects with carbon-14','how-scientists-date-ancient-objects-with-carbon-14','Living things absorb a trace of radioactive carbon that decays at a steady rate after death. Measuring what is left reveals an age of up to around 50,000 years.','<p>Most carbon atoms are carbon-12, but a tiny fraction is carbon-14, a radioactive form created when cosmic rays strike nitrogen in the upper atmosphere. Plants take up carbon-14 along with ordinary carbon during photosynthesis, and animals take it in by eating plants. While an organism is alive, its ratio of carbon-14 to carbon-12 stays close to that of the atmosphere.</p>
<p>When the organism dies, it stops taking in new carbon, and the carbon-14 it contains decays steadily. Its half-life is about 5,730 years: after that time, half of the original carbon-14 remains; after twice that time, a quarter remains, and so on.</p>
<h2>From measurement to calendar years</h2>
<p>Modern laboratories count carbon-14 atoms directly with accelerator mass spectrometry, which needs only a small sample. Because atmospheric carbon-14 has varied over time, raw results are calibrated against records from tree rings, cave formations and sediments with known ages.</p>
<h2>What it can date</h2>
<p>The method works on once-living material such as wood, bone, charcoal, shells and cloth. After roughly 50,000 years, too little carbon-14 remains to measure reliably, so older objects and rocks are dated with other radioactive isotopes.</p>','Most carbon atoms are carbon-12, but a tiny fraction is carbon-14, a radioactive form created when cosmic rays strike nitrogen in the upper atmosphere. Plants take up carbon-14 along with ordinary carbon during photosynthesis, and animals take it in by eating plants. While an organism is alive, its ratio of carbon-14 to carbon-12 stays close to that of the atmosphere.
When the organism dies, it stops taking in new carbon, and the carbon-14 it contains decays steadily. Its half-life is about 5,730 years: after that time, half of the original carbon-14 remains; after twice that time, a quarter remains, and so on.
From measurement to calendar years
Modern laboratories count carbon-14 atoms directly with accelerator mass spectrometry, which needs only a small sample. Because atmospheric carbon-14 has varied over time, raw results are calibrated against records from tree rings, cave formations and sediments with known ages.
What it can date
The method works on once-living material such as wood, bone, charcoal, shells and cloth. After roughly 50,000 years, too little carbon-14 remains to measure reliably, so older objects and rocks are dated with other radioactive isotopes.',2,8,'/media/covers/how-scientists-date-ancient-objects-with-carbon-14.svg','published','2026-10-10 06:12:40.563957','2026-10-08 06:12:40.563957','2026-10-31 07:12:40.756146',67);
INSERT INTO "documents" VALUES(55,'The life cycle of a star','the-life-cycle-of-a-star','Stars are born in clouds of gas, shine by fusing hydrogen and end as white dwarfs, neutron stars or black holes. Their mass decides which path they take.','<p>Stars form inside cold clouds of gas and dust. When a dense region collapses under its own gravity, it heats up until hydrogen nuclei in the core begin to fuse into helium. The energy released pushes outward and balances gravity, and a stable star is born.</p>
<p>A star spends most of its life in this hydrogen-burning phase, called the main sequence. Mass sets the pace: massive stars burn hot and bright and may last only a few million years, while small red dwarfs can shine for far longer than the current age of the universe. The Sun is roughly halfway through a main-sequence life of about ten billion years.</p>
<h2>Endings depend on mass</h2>
<p>When the core runs out of hydrogen, a star like the Sun swells into a red giant, sheds its outer layers as a glowing nebula and leaves behind a dense white dwarf. Much more massive stars fuse heavier elements in layers until the core collapses, triggering a supernova. What remains is either a neutron star or, for the heaviest cores, a black hole.</p>
<p>Supernovae scatter elements such as oxygen, carbon and iron into space, where they become part of new stars, planets and, eventually, living things.</p>','Stars form inside cold clouds of gas and dust. When a dense region collapses under its own gravity, it heats up until hydrogen nuclei in the core begin to fuse into helium. The energy released pushes outward and balances gravity, and a stable star is born.
A star spends most of its life in this hydrogen-burning phase, called the main sequence. Mass sets the pace: massive stars burn hot and bright and may last only a few million years, while small red dwarfs can shine for far longer than the current age of the universe. The Sun is roughly halfway through a main-sequence life of about ten billion years.
Endings depend on mass
When the core runs out of hydrogen, a star like the Sun swells into a red giant, sheds its outer layers as a glowing nebula and leaves behind a dense white dwarf. Much more massive stars fuse heavier elements in layers until the core collapses, triggering a supernova. What remains is either a neutron star or, for the heaviest cores, a black hole.
Supernovae scatter elements such as oxygen, carbon and iron into space, where they become part of new stars, planets and, eventually, living things.',2,9,'/media/covers/the-life-cycle-of-a-star.svg','published','2026-10-12 13:12:40.563957','2026-10-11 13:12:40.563957','2026-10-31 07:12:40.756146',24);
INSERT INTO "documents" VALUES(56,'Tardigrades: the toughest animals on Earth','tardigrades-the-toughest-animals-on-earth','These half-millimetre animals survive freezing, boiling, radiation and even the vacuum of space by entering a state of suspended animation.','<p>Tardigrades, also known as water bears or moss piglets, are tiny eight-legged animals usually less than a millimetre long. They live almost everywhere there is moisture, from garden moss and lichen to deep-sea sediments and mountain tops.</p>
<p>Their fame comes from extreme resilience. When their environment dries out, many species curl into a compact form called a tun and slow their metabolism to almost nothing. In this state they can endure temperatures close to absolute zero, brief heating far above boiling, high doses of radiation and pressures greater than those at the bottom of the ocean. Some have survived exposure to space on research missions and revived afterwards.</p>
<h2>How they do it</h2>
<p>As they dry out, tardigrades produce protective molecules, including special proteins that form glass-like structures around cell contents, preventing them from falling apart. One protein discovered in a tardigrade species appears to shield DNA from radiation damage.</p>
<h2>Why scientists care</h2>
<p>Understanding these mechanisms could help preserve vaccines and medicines without refrigeration and protect cells in other settings. Tardigrades are not indestructible, though: in their active state they are as vulnerable as any other small animal.</p>','Tardigrades, also known as water bears or moss piglets, are tiny eight-legged animals usually less than a millimetre long. They live almost everywhere there is moisture, from garden moss and lichen to deep-sea sediments and mountain tops.
Their fame comes from extreme resilience. When their environment dries out, many species curl into a compact form called a tun and slow their metabolism to almost nothing. In this state they can endure temperatures close to absolute zero, brief heating far above boiling, high doses of radiation and pressures greater than those at the bottom of the ocean. Some have survived exposure to space on research missions and revived afterwards.
How they do it
As they dry out, tardigrades produce protective molecules, including special proteins that form glass-like structures around cell contents, preventing them from falling apart. One protein discovered in a tardigrade species appears to shield DNA from radiation damage.
Why scientists care
Understanding these mechanisms could help preserve vaccines and medicines without refrigeration and protect cells in other settings. Tardigrades are not indestructible, though: in their active state they are as vulnerable as any other small animal.',2,6,'/media/covers/tardigrades-the-toughest-animals-on-earth.svg','published','2026-10-16 05:12:40.563957','2026-10-12 05:12:40.563957','2026-10-31 07:12:40.756146',55);
INSERT INTO "documents" VALUES(57,'Negotiating a salary offer without awkwardness','negotiating-a-salary-offer-without-awkwardness','Many people accept the first offer they receive. Preparation, a clear number and a collaborative tone make negotiation far less uncomfortable.','<p>Receiving a job offer feels like the finish line, but it is also the moment when you have the most leverage. The employer has chosen you and invested time in the hiring process. Polite negotiation is expected in many industries and rarely leads to an offer being withdrawn.</p>
<p>Preparation is the foundation. Research typical pay for the role, level and location using salary surveys, job postings and conversations with people in the field. Consider the whole package: base salary, bonuses, equity, holidays, flexibility, training budgets and benefits.</p>
<h2>During the conversation</h2>
<p>Thank the employer and express genuine enthusiasm. Then make a specific request supported by your research and the value you bring, for example a number slightly above your target to leave room for discussion. Keep the tone collaborative: you are solving a problem together. Silence after stating your number is fine; you do not need to fill it.</p>
<h2>If the salary cannot move</h2>
<p>Budgets are sometimes fixed. In that case, ask about other elements, such as a signing bonus, extra leave, remote days or an early salary review. Get the final agreement in writing, and whatever the outcome, keep the relationship positive.</p>','Receiving a job offer feels like the finish line, but it is also the moment when you have the most leverage. The employer has chosen you and invested time in the hiring process. Polite negotiation is expected in many industries and rarely leads to an offer being withdrawn.
Preparation is the foundation. Research typical pay for the role, level and location using salary surveys, job postings and conversations with people in the field. Consider the whole package: base salary, bonuses, equity, holidays, flexibility, training budgets and benefits.
During the conversation
Thank the employer and express genuine enthusiasm. Then make a specific request supported by your research and the value you bring, for example a number slightly above your target to leave room for discussion. Keep the tone collaborative: you are solving a problem together. Silence after stating your number is fine; you do not need to fill it.
If the salary cannot move
Budgets are sometimes fixed. In that case, ask about other elements, such as a signing bonus, extra leave, remote days or an early salary review. Get the final agreement in writing, and whatever the outcome, keep the relationship positive.',5,8,'/media/covers/negotiating-a-salary-offer-without-awkwardness.svg','published','2026-10-19 05:12:40.563957','2026-10-17 05:12:40.563957','2026-10-31 07:12:40.756146',8);
INSERT INTO "documents" VALUES(58,'What actually happens when you type a web address','what-actually-happens-when-you-type-a-web-address','Between pressing Enter and seeing a page, your browser looks up an address, opens a secure connection and downloads dozens of files. A step-by-step walk through.','<p>Typing a web address starts a short chain of conversations between computers. First, your browser needs a numeric IP address for the name you typed. It asks the Domain Name System, a distributed directory that maps names to addresses. Answers are cached at several levels, so popular sites resolve almost instantly.</p>
<p>Next, the browser opens a connection to that address and negotiates encryption using TLS. The server presents a certificate signed by an authority your device trusts, which proves you reached the real owner of the domain and not an impostor. The padlock icon summarises that check.</p>
<h2>Requesting the page</h2>
<p>With a secure channel in place, the browser sends an HTTP request for the page. The server replies with HTML, the skeleton of the page. While reading it, the browser discovers stylesheets, scripts, fonts and images and requests them too, often in parallel over the same connection.</p>
<h2>Building what you see</h2>
<p>The browser turns HTML into a tree of elements, applies styles, calculates the layout and paints pixels on the screen. Scripts can change the page afterwards, which is why some sites keep loading content as you scroll. All of this usually happens in well under a few seconds.</p>','Typing a web address starts a short chain of conversations between computers. First, your browser needs a numeric IP address for the name you typed. It asks the Domain Name System, a distributed directory that maps names to addresses. Answers are cached at several levels, so popular sites resolve almost instantly.
Next, the browser opens a connection to that address and negotiates encryption using TLS. The server presents a certificate signed by an authority your device trusts, which proves you reached the real owner of the domain and not an impostor. The padlock icon summarises that check.
Requesting the page
With a secure channel in place, the browser sends an HTTP request for the page. The server replies with HTML, the skeleton of the page. While reading it, the browser discovers stylesheets, scripts, fonts and images and requests them too, often in parallel over the same connection.
Building what you see
The browser turns HTML into a tree of elements, applies styles, calculates the layout and paints pixels on the screen. Scripts can change the page afterwards, which is why some sites keep loading content as you scroll. All of this usually happens in well under a few seconds.',1,7,'/media/covers/what-actually-happens-when-you-type-a-web-address.svg','published','2026-10-22 03:12:40.563957','2026-10-18 03:12:40.563957','2026-10-31 07:12:40.756146',13);
INSERT INTO "documents" VALUES(59,'Cloud storage or local backups? Building a sensible backup plan','cloud-storage-or-local-backups-building-a-sensible-backup-plan','Sync is not the same as backup. The 3-2-1 rule offers a simple way to protect photos and documents against theft, failure and mistakes.','<p>Many people assume their files are backed up because they sync to a cloud service. Sync keeps copies identical across devices, which also means that a deleted or encrypted file can disappear everywhere at once. A backup is a separate copy you can restore from, ideally including older versions.</p>
<p>A widely used guideline is the 3-2-1 rule: keep three copies of important data, on two different types of storage, with one copy off-site. For a household that might mean the files on your laptop, an external drive at home and a cloud backup service.</p>
<h2>Choosing the pieces</h2>
<p>External drives are cheap and fast to restore from, but they fail, get lost and are vulnerable to fire or theft. Cloud backup protects against local disasters and keeps file history, but restoring a large library over the internet can take time.</p>
<h2>The step most people skip</h2>
<p>Test a restore. Pick a few files every few months and recover them from each backup. A backup you have never restored is only a hope. Also turn on version history where it is available, because it is the main defence against ransomware and accidental overwrites.</p>','Many people assume their files are backed up because they sync to a cloud service. Sync keeps copies identical across devices, which also means that a deleted or encrypted file can disappear everywhere at once. A backup is a separate copy you can restore from, ideally including older versions.
A widely used guideline is the 3-2-1 rule: keep three copies of important data, on two different types of storage, with one copy off-site. For a household that might mean the files on your laptop, an external drive at home and a cloud backup service.
Choosing the pieces
External drives are cheap and fast to restore from, but they fail, get lost and are vulnerable to fire or theft. Cloud backup protects against local disasters and keeps file history, but restoring a large library over the internet can take time.
The step most people skip
Test a restore. Pick a few files every few months and recover them from each backup. A backup you have never restored is only a hope. Also turn on version history where it is available, because it is the main defence against ransomware and accidental overwrites.',1,9,'/media/covers/cloud-storage-or-local-backups-building-a-sensible-backup-plan.svg','published','2026-10-24 14:12:40.563957','2026-10-22 14:12:40.563957','2026-10-31 07:13:56.560893',51);
INSERT INTO "documents" VALUES(60,'Compound interest: the quiet engine of savings','compound-interest-the-quiet-engine-of-savings','Compound interest means earning returns on your previous returns. Time matters more than most people expect, for savings and for debt.','<p>Simple interest is paid only on the original amount. Compound interest is paid on the original amount plus the interest already earned. Each year the base grows a little, so the growth itself grows. Over short periods the difference is small; over decades it becomes large.</p>
<p>Imagine saving a fixed amount that grows at a steady rate each year. If you start ten years earlier, the money from those first years has a whole extra decade to compound. This is why starting to save early, even with small amounts, often matters more than saving larger amounts later.</p>
<h2>The rule of 72</h2>
<p>A quick way to estimate doubling time is to divide 72 by the annual percentage rate. At 6 percent, money roughly doubles in 12 years; at 9 percent, in about 8 years. It is an approximation, but a useful one.</p>
<h2>It works against you too</h2>
<p>The same maths applies to debt. Credit card balances with high interest rates can grow quickly if only minimum payments are made. Paying off expensive debt is often one of the best financial returns available. Remember also that inflation reduces purchasing power over time, so what matters is the return after inflation and fees.</p>','Simple interest is paid only on the original amount. Compound interest is paid on the original amount plus the interest already earned. Each year the base grows a little, so the growth itself grows. Over short periods the difference is small; over decades it becomes large.
Imagine saving a fixed amount that grows at a steady rate each year. If you start ten years earlier, the money from those first years has a whole extra decade to compound. This is why starting to save early, even with small amounts, often matters more than saving larger amounts later.
The rule of 72
A quick way to estimate doubling time is to divide 72 by the annual percentage rate. At 6 percent, money roughly doubles in 12 years; at 9 percent, in about 8 years. It is an approximation, but a useful one.
It works against you too
The same maths applies to debt. Credit card balances with high interest rates can grow quickly if only minimum payments are made. Paying off expensive debt is often one of the best financial returns available. Remember also that inflation reduces purchasing power over time, so what matters is the return after inflation and fees.',5,9,'/media/covers/compound-interest-the-quiet-engine-of-savings.svg','published','2026-10-27 23:12:40.563957','2026-10-23 23:12:40.563957','2026-10-31 07:12:40.756146',50);
CREATE TABLE likes (
	user_id INTEGER NOT NULL, 
	document_id INTEGER NOT NULL, 
	created_at DATETIME NOT NULL, 
	PRIMARY KEY (user_id, document_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	FOREIGN KEY(document_id) REFERENCES documents (id) ON DELETE CASCADE
);
INSERT INTO "likes" VALUES(4,2,'2026-05-21 13:12:40.563957');
INSERT INTO "likes" VALUES(20,2,'2026-05-18 13:12:40.563957');
INSERT INTO "likes" VALUES(5,2,'2026-05-11 13:12:40.563957');
INSERT INTO "likes" VALUES(21,2,'2026-05-06 13:12:40.563957');
INSERT INTO "likes" VALUES(12,2,'2026-05-17 13:12:40.563957');
INSERT INTO "likes" VALUES(17,2,'2026-05-17 13:12:40.563957');
INSERT INTO "likes" VALUES(13,2,'2026-05-17 13:12:40.563957');
INSERT INTO "likes" VALUES(14,2,'2026-05-26 13:12:40.563957');
INSERT INTO "likes" VALUES(19,3,'2026-05-29 05:12:40.563957');
INSERT INTO "likes" VALUES(11,3,'2026-05-30 05:12:40.563957');
INSERT INTO "likes" VALUES(10,3,'2026-05-17 05:12:40.563957');
INSERT INTO "likes" VALUES(20,3,'2026-05-23 05:12:40.563957');
INSERT INTO "likes" VALUES(15,3,'2026-05-17 05:12:40.563957');
INSERT INTO "likes" VALUES(17,3,'2026-05-28 05:12:40.563957');
INSERT INTO "likes" VALUES(19,4,'2026-05-30 00:12:40.563957');
INSERT INTO "likes" VALUES(11,4,'2026-05-19 00:12:40.563957');
INSERT INTO "likes" VALUES(18,4,'2026-05-17 00:12:40.563957');
INSERT INTO "likes" VALUES(11,5,'2026-05-26 05:12:40.563957');
INSERT INTO "likes" VALUES(20,6,'2026-05-22 04:12:40.563957');
INSERT INTO "likes" VALUES(3,6,'2026-05-23 04:12:40.563957');
INSERT INTO "likes" VALUES(19,6,'2026-05-24 04:12:40.563957');
INSERT INTO "likes" VALUES(4,6,'2026-05-19 04:12:40.563957');
INSERT INTO "likes" VALUES(13,6,'2026-06-07 04:12:40.563957');
INSERT INTO "likes" VALUES(11,6,'2026-06-07 04:12:40.563957');
INSERT INTO "likes" VALUES(12,6,'2026-05-27 04:12:40.563957');
INSERT INTO "likes" VALUES(20,7,'2026-05-25 23:12:40.563957');
INSERT INTO "likes" VALUES(19,7,'2026-05-26 23:12:40.563957');
INSERT INTO "likes" VALUES(14,7,'2026-05-27 23:12:40.563957');
INSERT INTO "likes" VALUES(11,7,'2026-05-28 23:12:40.563957');
INSERT INTO "likes" VALUES(15,7,'2026-05-22 23:12:40.563957');
INSERT INTO "likes" VALUES(16,7,'2026-06-03 23:12:40.563957');
INSERT INTO "likes" VALUES(18,7,'2026-05-21 23:12:40.563957');
INSERT INTO "likes" VALUES(15,8,'2026-05-25 11:12:40.563957');
INSERT INTO "likes" VALUES(4,8,'2026-06-12 11:12:40.563957');
INSERT INTO "likes" VALUES(21,8,'2026-06-05 11:12:40.563957');
INSERT INTO "likes" VALUES(17,9,'2026-06-03 02:12:40.563957');
INSERT INTO "likes" VALUES(15,9,'2026-06-06 02:12:40.563957');
INSERT INTO "likes" VALUES(20,9,'2026-06-11 02:12:40.563957');
INSERT INTO "likes" VALUES(5,9,'2026-06-09 02:12:40.563957');
INSERT INTO "likes" VALUES(4,9,'2026-06-06 02:12:40.563957');
INSERT INTO "likes" VALUES(3,9,'2026-06-06 02:12:40.563957');
INSERT INTO "likes" VALUES(19,9,'2026-06-11 02:12:40.563957');
INSERT INTO "likes" VALUES(21,9,'2026-06-02 02:12:40.563957');
INSERT INTO "likes" VALUES(16,10,'2026-06-05 20:12:40.563957');
INSERT INTO "likes" VALUES(18,10,'2026-06-13 20:12:40.563957');
INSERT INTO "likes" VALUES(20,12,'2026-06-08 12:12:40.563957');
INSERT INTO "likes" VALUES(4,12,'2026-06-07 12:12:40.563957');
INSERT INTO "likes" VALUES(17,13,'2026-06-20 14:12:40.563957');
INSERT INTO "likes" VALUES(11,14,'2026-06-16 02:12:40.563957');
INSERT INTO "likes" VALUES(3,14,'2026-06-17 02:12:40.563957');
INSERT INTO "likes" VALUES(13,15,'2026-06-17 19:12:40.563957');
INSERT INTO "likes" VALUES(4,15,'2026-06-18 19:12:40.563957');
INSERT INTO "likes" VALUES(20,15,'2026-06-20 19:12:40.563957');
INSERT INTO "likes" VALUES(16,15,'2026-06-14 19:12:40.563957');
INSERT INTO "likes" VALUES(3,15,'2026-07-03 19:12:40.563957');
INSERT INTO "likes" VALUES(11,15,'2026-06-22 19:12:40.563957');
INSERT INTO "likes" VALUES(16,16,'2026-06-24 11:12:40.563957');
INSERT INTO "likes" VALUES(3,16,'2026-06-23 11:12:40.563957');
INSERT INTO "likes" VALUES(4,16,'2026-07-05 11:12:40.563957');
INSERT INTO "likes" VALUES(17,16,'2026-07-02 11:12:40.563957');
INSERT INTO "likes" VALUES(5,16,'2026-07-01 11:12:40.563957');
INSERT INTO "likes" VALUES(18,16,'2026-06-30 11:12:40.563957');
INSERT INTO "likes" VALUES(21,16,'2026-07-01 11:12:40.563957');
INSERT INTO "likes" VALUES(13,17,'2026-06-21 21:12:40.563957');
INSERT INTO "likes" VALUES(18,17,'2026-07-10 21:12:40.563957');
INSERT INTO "likes" VALUES(19,17,'2026-07-01 21:12:40.563957');
INSERT INTO "likes" VALUES(17,17,'2026-06-21 21:12:40.563957');
INSERT INTO "likes" VALUES(12,17,'2026-06-24 21:12:40.563957');
INSERT INTO "likes" VALUES(5,17,'2026-06-21 21:12:40.563957');
INSERT INTO "likes" VALUES(11,17,'2026-07-08 21:12:40.563957');
INSERT INTO "likes" VALUES(20,17,'2026-07-09 21:12:40.563957');
INSERT INTO "likes" VALUES(16,18,'2026-07-12 00:12:40.563957');
INSERT INTO "likes" VALUES(20,18,'2026-07-05 00:12:40.563957');
INSERT INTO "likes" VALUES(21,19,'2026-07-05 21:12:40.563957');
INSERT INTO "likes" VALUES(20,20,'2026-07-09 23:12:40.563957');
INSERT INTO "likes" VALUES(19,20,'2026-07-07 23:12:40.563957');
INSERT INTO "likes" VALUES(17,20,'2026-07-15 23:12:40.563957');
INSERT INTO "likes" VALUES(10,20,'2026-07-17 23:12:40.563957');
INSERT INTO "likes" VALUES(16,20,'2026-07-18 23:12:40.563957');
INSERT INTO "likes" VALUES(18,20,'2026-07-10 23:12:40.563957');
INSERT INTO "likes" VALUES(13,20,'2026-07-03 23:12:40.563957');
INSERT INTO "likes" VALUES(15,20,'2026-07-18 23:12:40.563957');
INSERT INTO "likes" VALUES(21,20,'2026-07-17 23:12:40.563957');
INSERT INTO "likes" VALUES(5,21,'2026-07-12 01:12:40.563957');
INSERT INTO "likes" VALUES(19,21,'2026-07-11 01:12:40.563957');
INSERT INTO "likes" VALUES(12,21,'2026-07-05 01:12:40.563957');
INSERT INTO "likes" VALUES(12,22,'2026-07-16 01:12:40.563957');
INSERT INTO "likes" VALUES(14,22,'2026-07-21 01:12:40.563957');
INSERT INTO "likes" VALUES(18,24,'2026-07-23 03:12:40.563957');
INSERT INTO "likes" VALUES(19,24,'2026-07-14 03:12:40.563957');
INSERT INTO "likes" VALUES(14,24,'2026-07-16 03:12:40.563957');
INSERT INTO "likes" VALUES(20,25,'2026-07-30 03:12:40.563957');
INSERT INTO "likes" VALUES(5,25,'2026-07-22 03:12:40.563957');
INSERT INTO "likes" VALUES(13,25,'2026-07-26 03:12:40.563957');
INSERT INTO "likes" VALUES(15,25,'2026-07-29 03:12:40.563957');
INSERT INTO "likes" VALUES(10,25,'2026-07-24 03:12:40.563957');
INSERT INTO "likes" VALUES(4,26,'2026-07-26 14:12:40.563957');
INSERT INTO "likes" VALUES(17,26,'2026-07-27 14:12:40.563957');
INSERT INTO "likes" VALUES(11,26,'2026-07-21 14:12:40.563957');
INSERT INTO "likes" VALUES(12,26,'2026-07-20 14:12:40.563957');
INSERT INTO "likes" VALUES(14,26,'2026-08-02 14:12:40.563957');
INSERT INTO "likes" VALUES(16,26,'2026-07-21 14:12:40.563957');
INSERT INTO "likes" VALUES(3,26,'2026-07-23 14:12:40.563957');
INSERT INTO "likes" VALUES(15,27,'2026-08-08 13:12:40.563957');
INSERT INTO "likes" VALUES(20,27,'2026-07-22 13:12:40.563957');
INSERT INTO "likes" VALUES(17,27,'2026-07-30 13:12:40.563957');
INSERT INTO "likes" VALUES(10,27,'2026-08-03 13:12:40.563957');
INSERT INTO "likes" VALUES(5,27,'2026-07-21 13:12:40.563957');
INSERT INTO "likes" VALUES(13,27,'2026-07-23 13:12:40.563957');
INSERT INTO "likes" VALUES(19,27,'2026-08-05 13:12:40.563957');
INSERT INTO "likes" VALUES(13,28,'2026-07-27 13:12:40.563957');
INSERT INTO "likes" VALUES(17,29,'2026-08-05 20:12:40.563957');
INSERT INTO "likes" VALUES(14,29,'2026-08-03 20:12:40.563957');
INSERT INTO "likes" VALUES(4,29,'2026-07-30 20:12:40.563957');
INSERT INTO "likes" VALUES(15,30,'2026-07-31 03:12:40.563957');
INSERT INTO "likes" VALUES(19,31,'2026-08-08 05:12:40.563957');
INSERT INTO "likes" VALUES(3,31,'2026-08-19 05:12:40.563957');
INSERT INTO "likes" VALUES(20,31,'2026-08-04 05:12:40.563957');
INSERT INTO "likes" VALUES(21,31,'2026-08-16 05:12:40.563957');
INSERT INTO "likes" VALUES(16,31,'2026-08-20 05:12:40.563957');
INSERT INTO "likes" VALUES(18,31,'2026-08-06 05:12:40.563957');
INSERT INTO "likes" VALUES(14,31,'2026-08-04 05:12:40.563957');
INSERT INTO "likes" VALUES(13,31,'2026-08-16 05:12:40.563957');
INSERT INTO "likes" VALUES(11,31,'2026-08-05 05:12:40.563957');
INSERT INTO "likes" VALUES(16,32,'2026-08-24 04:12:40.563957');
INSERT INTO "likes" VALUES(4,32,'2026-08-23 04:12:40.563957');
INSERT INTO "likes" VALUES(11,32,'2026-08-09 04:12:40.563957');
INSERT INTO "likes" VALUES(13,32,'2026-08-21 04:12:40.563957');
INSERT INTO "likes" VALUES(14,32,'2026-08-08 04:12:40.563957');
INSERT INTO "likes" VALUES(3,33,'2026-08-20 11:12:40.563957');
INSERT INTO "likes" VALUES(20,33,'2026-08-20 11:12:40.563957');
INSERT INTO "likes" VALUES(18,33,'2026-08-25 11:12:40.563957');
INSERT INTO "likes" VALUES(15,34,'2026-08-29 18:12:40.563957');
INSERT INTO "likes" VALUES(10,34,'2026-08-22 18:12:40.563957');
INSERT INTO "likes" VALUES(18,34,'2026-08-20 18:12:40.563957');
INSERT INTO "likes" VALUES(3,34,'2026-08-25 18:12:40.563957');
INSERT INTO "likes" VALUES(12,35,'2026-08-17 19:12:40.563957');
INSERT INTO "likes" VALUES(19,36,'2026-08-30 12:12:40.563957');
INSERT INTO "likes" VALUES(11,36,'2026-09-02 12:12:40.563957');
INSERT INTO "likes" VALUES(18,37,'2026-08-19 15:12:40.563957');
INSERT INTO "likes" VALUES(15,38,'2026-09-06 14:12:40.563957');
INSERT INTO "likes" VALUES(4,38,'2026-08-26 14:12:40.563957');
INSERT INTO "likes" VALUES(3,38,'2026-08-28 14:12:40.563957');
INSERT INTO "likes" VALUES(17,38,'2026-09-08 14:12:40.563957');
INSERT INTO "likes" VALUES(12,38,'2026-09-03 14:12:40.563957');
INSERT INTO "likes" VALUES(11,38,'2026-09-02 14:12:40.563957');
INSERT INTO "likes" VALUES(18,39,'2026-09-09 04:12:40.563957');
INSERT INTO "likes" VALUES(11,39,'2026-09-07 04:12:40.563957');
INSERT INTO "likes" VALUES(16,39,'2026-09-06 04:12:40.563957');
INSERT INTO "likes" VALUES(17,39,'2026-09-02 04:12:40.563957');
INSERT INTO "likes" VALUES(15,39,'2026-08-31 04:12:40.563957');
INSERT INTO "likes" VALUES(20,39,'2026-09-08 04:12:40.563957');
INSERT INTO "likes" VALUES(16,40,'2026-08-29 11:12:40.563957');
INSERT INTO "likes" VALUES(3,40,'2026-09-15 11:12:40.563957');
INSERT INTO "likes" VALUES(20,40,'2026-09-12 11:12:40.563957');
INSERT INTO "likes" VALUES(12,40,'2026-09-08 11:12:40.563957');
INSERT INTO "likes" VALUES(17,40,'2026-08-31 11:12:40.563957');
INSERT INTO "likes" VALUES(13,40,'2026-09-15 11:12:40.563957');
INSERT INTO "likes" VALUES(15,40,'2026-09-12 11:12:40.563957');
INSERT INTO "likes" VALUES(14,40,'2026-08-30 11:12:40.563957');
INSERT INTO "likes" VALUES(5,40,'2026-09-01 11:12:40.563957');
INSERT INTO "likes" VALUES(13,41,'2026-09-16 04:12:40.563957');
INSERT INTO "likes" VALUES(18,41,'2026-09-19 04:12:40.563957');
INSERT INTO "likes" VALUES(5,41,'2026-09-11 04:12:40.563957');
INSERT INTO "likes" VALUES(14,41,'2026-09-14 04:12:40.563957');
INSERT INTO "likes" VALUES(17,41,'2026-09-12 04:12:40.563957');
INSERT INTO "likes" VALUES(21,41,'2026-09-10 04:12:40.563957');
INSERT INTO "likes" VALUES(16,41,'2026-09-10 04:12:40.563957');
INSERT INTO "likes" VALUES(19,41,'2026-09-06 04:12:40.563957');
INSERT INTO "likes" VALUES(4,41,'2026-09-02 04:12:40.563957');
INSERT INTO "likes" VALUES(11,43,'2026-09-13 17:12:40.563957');
INSERT INTO "likes" VALUES(18,43,'2026-09-21 17:12:40.563957');
INSERT INTO "likes" VALUES(20,43,'2026-09-11 17:12:40.563957');
INSERT INTO "likes" VALUES(4,43,'2026-09-22 17:12:40.563957');
INSERT INTO "likes" VALUES(19,43,'2026-09-07 17:12:40.563957');
INSERT INTO "likes" VALUES(16,43,'2026-09-16 17:12:40.563957');
INSERT INTO "likes" VALUES(14,43,'2026-09-08 17:12:40.563957');
INSERT INTO "likes" VALUES(21,43,'2026-09-10 17:12:40.563957');
INSERT INTO "likes" VALUES(3,43,'2026-09-25 17:12:40.563957');
INSERT INTO "likes" VALUES(20,44,'2026-09-29 23:12:40.563957');
INSERT INTO "likes" VALUES(19,44,'2026-09-17 23:12:40.563957');
INSERT INTO "likes" VALUES(11,44,'2026-09-12 23:12:40.563957');
INSERT INTO "likes" VALUES(12,44,'2026-09-10 23:12:40.563957');
INSERT INTO "likes" VALUES(18,44,'2026-09-14 23:12:40.563957');
INSERT INTO "likes" VALUES(14,44,'2026-09-23 23:12:40.563957');
INSERT INTO "likes" VALUES(5,44,'2026-09-21 23:12:40.563957');
INSERT INTO "likes" VALUES(4,45,'2026-09-30 15:12:40.563957');
INSERT INTO "likes" VALUES(19,45,'2026-09-24 15:12:40.563957');
INSERT INTO "likes" VALUES(13,45,'2026-09-26 15:12:40.563957');
INSERT INTO "likes" VALUES(14,45,'2026-09-19 15:12:40.563957');
INSERT INTO "likes" VALUES(21,45,'2026-09-30 15:12:40.563957');
INSERT INTO "likes" VALUES(3,45,'2026-09-18 15:12:40.563957');
INSERT INTO "likes" VALUES(10,45,'2026-09-28 15:12:40.563957');
INSERT INTO "likes" VALUES(18,45,'2026-09-22 15:12:40.563957');
INSERT INTO "likes" VALUES(20,45,'2026-09-17 15:12:40.563957');
INSERT INTO "likes" VALUES(21,47,'2026-09-20 11:12:40.563957');
INSERT INTO "likes" VALUES(11,47,'2026-10-08 11:12:40.563957');
INSERT INTO "likes" VALUES(10,47,'2026-10-02 11:12:40.563957');
INSERT INTO "likes" VALUES(20,47,'2026-09-26 11:12:40.563957');
INSERT INTO "likes" VALUES(3,47,'2026-10-01 11:12:40.563957');
INSERT INTO "likes" VALUES(13,47,'2026-09-28 11:12:40.563957');
INSERT INTO "likes" VALUES(18,47,'2026-09-26 11:12:40.563957');
INSERT INTO "likes" VALUES(16,47,'2026-09-23 11:12:40.563957');
INSERT INTO "likes" VALUES(14,47,'2026-09-20 11:12:40.563957');
INSERT INTO "likes" VALUES(15,48,'2026-10-11 03:12:40.563957');
INSERT INTO "likes" VALUES(11,48,'2026-10-12 03:12:40.563957');
INSERT INTO "likes" VALUES(19,48,'2026-09-25 03:12:40.563957');
INSERT INTO "likes" VALUES(16,48,'2026-10-06 03:12:40.563957');
INSERT INTO "likes" VALUES(10,48,'2026-09-30 03:12:40.563957');
INSERT INTO "likes" VALUES(3,48,'2026-09-25 03:12:40.563957');
INSERT INTO "likes" VALUES(17,48,'2026-09-23 03:12:40.563957');
INSERT INTO "likes" VALUES(4,48,'2026-09-24 03:12:40.563957');
INSERT INTO "likes" VALUES(21,48,'2026-09-24 03:12:40.563957');
INSERT INTO "likes" VALUES(18,49,'2026-10-08 02:12:40.563957');
INSERT INTO "likes" VALUES(5,49,'2026-10-07 02:12:40.563957');
INSERT INTO "likes" VALUES(17,49,'2026-09-27 02:12:40.563957');
INSERT INTO "likes" VALUES(20,49,'2026-10-12 02:12:40.563957');
INSERT INTO "likes" VALUES(16,49,'2026-10-02 02:12:40.563957');
INSERT INTO "likes" VALUES(19,49,'2026-09-25 02:12:40.563957');
INSERT INTO "likes" VALUES(3,50,'2026-10-11 12:12:40.563957');
INSERT INTO "likes" VALUES(10,51,'2026-10-06 16:12:40.563957');
INSERT INTO "likes" VALUES(19,51,'2026-09-30 16:12:40.563957');
INSERT INTO "likes" VALUES(16,51,'2026-10-18 16:12:40.563957');
INSERT INTO "likes" VALUES(20,51,'2026-10-07 16:12:40.563957');
INSERT INTO "likes" VALUES(12,51,'2026-10-15 16:12:40.563957');
INSERT INTO "likes" VALUES(11,51,'2026-10-12 16:12:40.563957');
INSERT INTO "likes" VALUES(5,51,'2026-10-02 16:12:40.563957');
INSERT INTO "likes" VALUES(16,52,'2026-10-08 04:12:40.563957');
INSERT INTO "likes" VALUES(19,52,'2026-10-19 04:12:40.563957');
INSERT INTO "likes" VALUES(17,52,'2026-10-24 04:12:40.563957');
INSERT INTO "likes" VALUES(11,52,'2026-10-04 04:12:40.563957');
INSERT INTO "likes" VALUES(18,52,'2026-10-19 04:12:40.563957');
INSERT INTO "likes" VALUES(12,52,'2026-10-23 04:12:40.563957');
INSERT INTO "likes" VALUES(10,52,'2026-10-05 04:12:40.563957');
INSERT INTO "likes" VALUES(5,52,'2026-10-11 04:12:40.563957');
INSERT INTO "likes" VALUES(18,53,'2026-10-25 22:12:40.563957');
INSERT INTO "likes" VALUES(11,53,'2026-10-25 22:12:40.563957');
INSERT INTO "likes" VALUES(4,53,'2026-10-13 22:12:40.563957');
INSERT INTO "likes" VALUES(10,53,'2026-10-08 22:12:40.563957');
INSERT INTO "likes" VALUES(20,53,'2026-10-12 22:12:40.563957');
INSERT INTO "likes" VALUES(19,53,'2026-10-19 22:12:40.563957');
INSERT INTO "likes" VALUES(16,53,'2026-10-16 22:12:40.563957');
INSERT INTO "likes" VALUES(16,54,'2026-10-28 06:12:40.563957');
INSERT INTO "likes" VALUES(12,54,'2026-10-11 06:12:40.563957');
INSERT INTO "likes" VALUES(10,56,'2026-10-19 05:12:40.563957');
INSERT INTO "likes" VALUES(19,56,'2026-11-01 05:12:40.563957');
INSERT INTO "likes" VALUES(21,56,'2026-10-19 05:12:40.563957');
INSERT INTO "likes" VALUES(13,56,'2026-11-04 05:12:40.563957');
INSERT INTO "likes" VALUES(14,56,'2026-10-27 05:12:40.563957');
INSERT INTO "likes" VALUES(15,56,'2026-11-02 05:12:40.563957');
INSERT INTO "likes" VALUES(5,56,'2026-11-01 05:12:40.563957');
INSERT INTO "likes" VALUES(12,56,'2026-10-23 05:12:40.563957');
INSERT INTO "likes" VALUES(4,56,'2026-10-30 05:12:40.563957');
INSERT INTO "likes" VALUES(13,58,'2026-11-10 03:12:40.563957');
INSERT INTO "likes" VALUES(12,58,'2026-11-05 03:12:40.563957');
INSERT INTO "likes" VALUES(15,58,'2026-10-23 03:12:40.563957');
INSERT INTO "likes" VALUES(4,58,'2026-10-25 03:12:40.563957');
INSERT INTO "likes" VALUES(14,58,'2026-10-23 03:12:40.563957');
INSERT INTO "likes" VALUES(18,59,'2026-10-27 14:12:40.563957');
INSERT INTO "likes" VALUES(4,59,'2026-11-03 14:12:40.563957');
INSERT INTO "likes" VALUES(14,59,'2026-10-31 14:12:40.563957');
INSERT INTO "likes" VALUES(15,59,'2026-10-27 14:12:40.563957');
INSERT INTO "likes" VALUES(12,59,'2026-10-31 14:12:40.563957');
INSERT INTO "likes" VALUES(21,59,'2026-11-06 14:12:40.563957');
INSERT INTO "likes" VALUES(19,59,'2026-10-30 14:12:40.563957');
INSERT INTO "likes" VALUES(14,60,'2026-11-14 23:12:40.563957');
INSERT INTO "likes" VALUES(11,60,'2026-10-28 23:12:40.563957');
INSERT INTO "likes" VALUES(5,60,'2026-11-04 23:12:40.563957');
CREATE TABLE permissions (
	id INTEGER NOT NULL, 
	code VARCHAR(60) NOT NULL, 
	description VARCHAR(255) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (code)
);
INSERT INTO "permissions" VALUES(1,'users.manage','Create, edit, deactivate user accounts and change their roles');
INSERT INTO "permissions" VALUES(2,'roles.manage','Assign permissions to roles');
INSERT INTO "permissions" VALUES(3,'logs.view','View system (audit) logs and raw search/click logs');
INSERT INTO "permissions" VALUES(4,'settings.manage','Configure global site settings');
INSERT INTO "permissions" VALUES(5,'documents.manage','Create, edit and delete articles');
INSERT INTO "permissions" VALUES(6,'documents.publish','Publish and unpublish articles');
INSERT INTO "permissions" VALUES(7,'taxonomy.manage','Create, edit and delete categories and tags');
INSERT INTO "permissions" VALUES(8,'comments.moderate','Review comments, mark spam, manage spam rules');
INSERT INTO "permissions" VALUES(9,'reports.handle','Review and resolve user reports (flags)');
INSERT INTO "permissions" VALUES(10,'seo.manage','Edit SEO metadata (titles, descriptions, keywords, alt text)');
INSERT INTO "permissions" VALUES(11,'analytics.view','View the analytics dashboard');
CREATE TABLE ratings (
	user_id INTEGER NOT NULL, 
	document_id INTEGER NOT NULL, 
	score INTEGER NOT NULL, 
	created_at DATETIME NOT NULL, 
	PRIMARY KEY (user_id, document_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	FOREIGN KEY(document_id) REFERENCES documents (id) ON DELETE CASCADE
);
INSERT INTO "ratings" VALUES(12,2,5,'2026-05-18 13:12:40.563957');
INSERT INTO "ratings" VALUES(17,2,5,'2026-05-06 13:12:40.563957');
INSERT INTO "ratings" VALUES(13,2,2,'2026-05-14 13:12:40.563957');
INSERT INTO "ratings" VALUES(5,2,3,'2026-05-16 13:12:40.563957');
INSERT INTO "ratings" VALUES(15,3,5,'2026-05-20 05:12:40.563957');
INSERT INTO "ratings" VALUES(13,3,4,'2026-05-14 05:12:40.563957');
INSERT INTO "ratings" VALUES(20,4,4,'2026-05-17 00:12:40.563957');
INSERT INTO "ratings" VALUES(4,4,5,'2026-05-31 00:12:40.563957');
INSERT INTO "ratings" VALUES(17,4,5,'2026-05-23 00:12:40.563957');
INSERT INTO "ratings" VALUES(11,4,3,'2026-05-30 00:12:40.563957');
INSERT INTO "ratings" VALUES(20,5,5,'2026-05-29 05:12:40.563957');
INSERT INTO "ratings" VALUES(5,5,2,'2026-05-25 05:12:40.563957');
INSERT INTO "ratings" VALUES(18,6,5,'2026-05-30 04:12:40.563957');
INSERT INTO "ratings" VALUES(12,6,3,'2026-06-03 04:12:40.563957');
INSERT INTO "ratings" VALUES(3,6,3,'2026-06-07 04:12:40.563957');
INSERT INTO "ratings" VALUES(15,7,2,'2026-05-27 23:12:40.563957');
INSERT INTO "ratings" VALUES(12,7,3,'2026-06-04 23:12:40.563957');
INSERT INTO "ratings" VALUES(20,7,5,'2026-06-05 23:12:40.563957');
INSERT INTO "ratings" VALUES(19,7,5,'2026-06-04 23:12:40.563957');
INSERT INTO "ratings" VALUES(15,8,4,'2026-06-13 11:12:40.563957');
INSERT INTO "ratings" VALUES(18,8,5,'2026-05-25 11:12:40.563957');
INSERT INTO "ratings" VALUES(20,8,4,'2026-06-07 11:12:40.563957');
INSERT INTO "ratings" VALUES(3,8,4,'2026-05-25 11:12:40.563957');
INSERT INTO "ratings" VALUES(21,8,5,'2026-05-31 11:12:40.563957');
INSERT INTO "ratings" VALUES(13,9,4,'2026-06-17 02:12:40.563957');
INSERT INTO "ratings" VALUES(18,9,4,'2026-06-13 02:12:40.563957');
INSERT INTO "ratings" VALUES(5,9,3,'2026-06-15 02:12:40.563957');
INSERT INTO "ratings" VALUES(20,9,2,'2026-06-14 02:12:40.563957');
INSERT INTO "ratings" VALUES(17,9,3,'2026-06-10 02:12:40.563957');
INSERT INTO "ratings" VALUES(11,9,4,'2026-05-28 02:12:40.563957');
INSERT INTO "ratings" VALUES(13,10,4,'2026-06-19 20:12:40.563957');
INSERT INTO "ratings" VALUES(20,12,4,'2026-06-16 12:12:40.563957');
INSERT INTO "ratings" VALUES(15,13,4,'2026-06-13 14:12:40.563957');
INSERT INTO "ratings" VALUES(17,13,5,'2026-06-26 14:12:40.563957');
INSERT INTO "ratings" VALUES(18,16,4,'2026-06-24 11:12:40.563957');
INSERT INTO "ratings" VALUES(14,17,4,'2026-06-25 21:12:40.563957');
INSERT INTO "ratings" VALUES(10,17,3,'2026-06-29 21:12:40.563957');
INSERT INTO "ratings" VALUES(5,17,4,'2026-07-09 21:12:40.563957');
INSERT INTO "ratings" VALUES(3,17,4,'2026-07-07 21:12:40.563957');
INSERT INTO "ratings" VALUES(14,19,3,'2026-07-11 21:12:40.563957');
INSERT INTO "ratings" VALUES(15,19,3,'2026-07-04 21:12:40.563957');
INSERT INTO "ratings" VALUES(10,19,4,'2026-07-09 21:12:40.563957');
INSERT INTO "ratings" VALUES(3,19,4,'2026-07-02 21:12:40.563957');
INSERT INTO "ratings" VALUES(17,19,4,'2026-06-29 21:12:40.563957');
INSERT INTO "ratings" VALUES(17,20,5,'2026-07-05 23:12:40.563957');
INSERT INTO "ratings" VALUES(20,20,3,'2026-06-29 23:12:40.563957');
INSERT INTO "ratings" VALUES(19,20,4,'2026-07-02 23:12:40.563957');
INSERT INTO "ratings" VALUES(16,20,5,'2026-07-05 23:12:40.563957');
INSERT INTO "ratings" VALUES(3,20,5,'2026-07-12 23:12:40.563957');
INSERT INTO "ratings" VALUES(11,20,4,'2026-07-09 23:12:40.563957');
INSERT INTO "ratings" VALUES(12,20,4,'2026-07-19 23:12:40.563957');
INSERT INTO "ratings" VALUES(13,21,5,'2026-07-06 01:12:40.563957');
INSERT INTO "ratings" VALUES(17,21,5,'2026-07-13 01:12:40.563957');
INSERT INTO "ratings" VALUES(3,21,4,'2026-07-21 01:12:40.563957');
INSERT INTO "ratings" VALUES(14,21,5,'2026-07-03 01:12:40.563957');
INSERT INTO "ratings" VALUES(21,22,5,'2026-07-23 01:12:40.563957');
INSERT INTO "ratings" VALUES(5,22,5,'2026-07-20 01:12:40.563957');
INSERT INTO "ratings" VALUES(19,22,5,'2026-07-19 01:12:40.563957');
INSERT INTO "ratings" VALUES(11,22,2,'2026-07-07 01:12:40.563957');
INSERT INTO "ratings" VALUES(16,22,5,'2026-07-15 01:12:40.563957');
INSERT INTO "ratings" VALUES(20,22,4,'2026-07-16 01:12:40.563957');
INSERT INTO "ratings" VALUES(4,22,4,'2026-07-06 01:12:40.563957');
INSERT INTO "ratings" VALUES(3,24,5,'2026-07-17 03:12:40.563957');
INSERT INTO "ratings" VALUES(5,24,4,'2026-07-24 03:12:40.563957');
INSERT INTO "ratings" VALUES(14,24,3,'2026-07-15 03:12:40.563957');
INSERT INTO "ratings" VALUES(15,24,5,'2026-07-21 03:12:40.563957');
INSERT INTO "ratings" VALUES(17,25,3,'2026-07-16 03:12:40.563957');
INSERT INTO "ratings" VALUES(13,25,5,'2026-07-17 03:12:40.563957');
INSERT INTO "ratings" VALUES(11,25,4,'2026-07-15 03:12:40.563957');
INSERT INTO "ratings" VALUES(5,27,5,'2026-07-26 13:12:40.563957');
INSERT INTO "ratings" VALUES(18,27,4,'2026-07-26 13:12:40.563957');
INSERT INTO "ratings" VALUES(21,27,4,'2026-08-06 13:12:40.563957');
INSERT INTO "ratings" VALUES(13,27,4,'2026-08-03 13:12:40.563957');
INSERT INTO "ratings" VALUES(13,28,3,'2026-08-11 13:12:40.563957');
INSERT INTO "ratings" VALUES(10,28,4,'2026-07-26 13:12:40.563957');
INSERT INTO "ratings" VALUES(18,29,4,'2026-08-05 20:12:40.563957');
INSERT INTO "ratings" VALUES(12,29,4,'2026-07-27 20:12:40.563957');
INSERT INTO "ratings" VALUES(11,29,3,'2026-08-10 20:12:40.563957');
INSERT INTO "ratings" VALUES(10,29,5,'2026-07-27 20:12:40.563957');
INSERT INTO "ratings" VALUES(15,30,4,'2026-08-18 03:12:40.563957');
INSERT INTO "ratings" VALUES(13,31,2,'2026-08-06 05:12:40.563957');
INSERT INTO "ratings" VALUES(19,31,5,'2026-08-21 05:12:40.563957');
INSERT INTO "ratings" VALUES(3,31,4,'2026-08-13 05:12:40.563957');
INSERT INTO "ratings" VALUES(20,31,4,'2026-08-12 05:12:40.563957');
INSERT INTO "ratings" VALUES(16,31,5,'2026-08-12 05:12:40.563957');
INSERT INTO "ratings" VALUES(21,31,4,'2026-08-02 05:12:40.563957');
INSERT INTO "ratings" VALUES(12,31,3,'2026-08-05 05:12:40.563957');
INSERT INTO "ratings" VALUES(3,32,5,'2026-08-14 04:12:40.563957');
INSERT INTO "ratings" VALUES(20,32,4,'2026-08-17 04:12:40.563957');
INSERT INTO "ratings" VALUES(21,32,4,'2026-08-12 04:12:40.563957');
INSERT INTO "ratings" VALUES(10,32,5,'2026-08-22 04:12:40.563957');
INSERT INTO "ratings" VALUES(14,32,3,'2026-08-20 04:12:40.563957');
INSERT INTO "ratings" VALUES(17,32,4,'2026-08-15 04:12:40.563957');
INSERT INTO "ratings" VALUES(17,33,5,'2026-08-25 11:12:40.563957');
INSERT INTO "ratings" VALUES(20,33,5,'2026-08-10 11:12:40.563957');
INSERT INTO "ratings" VALUES(12,33,4,'2026-08-21 11:12:40.563957');
INSERT INTO "ratings" VALUES(11,33,4,'2026-08-10 11:12:40.563957');
INSERT INTO "ratings" VALUES(19,33,5,'2026-08-12 11:12:40.563957');
INSERT INTO "ratings" VALUES(15,36,3,'2026-08-26 12:12:40.563957');
INSERT INTO "ratings" VALUES(18,36,4,'2026-08-25 12:12:40.563957');
INSERT INTO "ratings" VALUES(3,36,5,'2026-08-29 12:12:40.563957');
INSERT INTO "ratings" VALUES(16,36,5,'2026-08-27 12:12:40.563957');
INSERT INTO "ratings" VALUES(3,37,2,'2026-08-19 15:12:40.563957');
INSERT INTO "ratings" VALUES(11,37,5,'2026-08-30 15:12:40.563957');
INSERT INTO "ratings" VALUES(13,37,3,'2026-08-28 15:12:40.563957');
INSERT INTO "ratings" VALUES(5,37,5,'2026-08-26 15:12:40.563957');
INSERT INTO "ratings" VALUES(14,37,4,'2026-09-06 15:12:40.563957');
INSERT INTO "ratings" VALUES(17,37,4,'2026-08-29 15:12:40.563957');
INSERT INTO "ratings" VALUES(11,38,3,'2026-08-22 14:12:40.563957');
INSERT INTO "ratings" VALUES(13,38,3,'2026-09-06 14:12:40.563957');
INSERT INTO "ratings" VALUES(19,38,5,'2026-08-26 14:12:40.563957');
INSERT INTO "ratings" VALUES(4,38,3,'2026-09-11 14:12:40.563957');
INSERT INTO "ratings" VALUES(20,38,5,'2026-09-05 14:12:40.563957');
INSERT INTO "ratings" VALUES(5,38,5,'2026-09-10 14:12:40.563957');
INSERT INTO "ratings" VALUES(16,40,5,'2026-08-30 11:12:40.563957');
INSERT INTO "ratings" VALUES(17,40,4,'2026-09-17 11:12:40.563957');
INSERT INTO "ratings" VALUES(10,40,5,'2026-08-30 11:12:40.563957');
INSERT INTO "ratings" VALUES(3,40,5,'2026-09-14 11:12:40.563957');
INSERT INTO "ratings" VALUES(20,41,3,'2026-09-16 04:12:40.563957');
INSERT INTO "ratings" VALUES(21,41,4,'2026-09-19 04:12:40.563957');
INSERT INTO "ratings" VALUES(18,41,3,'2026-09-10 04:12:40.563957');
INSERT INTO "ratings" VALUES(13,41,5,'2026-09-20 04:12:40.563957');
INSERT INTO "ratings" VALUES(16,42,3,'2026-09-11 18:12:40.563957');
INSERT INTO "ratings" VALUES(10,42,4,'2026-09-22 18:12:40.563957');
INSERT INTO "ratings" VALUES(11,42,4,'2026-09-11 18:12:40.563957');
INSERT INTO "ratings" VALUES(17,42,3,'2026-09-06 18:12:40.563957');
INSERT INTO "ratings" VALUES(3,43,5,'2026-09-19 17:12:40.563957');
INSERT INTO "ratings" VALUES(16,43,5,'2026-09-13 17:12:40.563957');
INSERT INTO "ratings" VALUES(13,44,4,'2026-09-13 23:12:40.563957');
INSERT INTO "ratings" VALUES(16,44,4,'2026-09-22 23:12:40.563957');
INSERT INTO "ratings" VALUES(20,44,3,'2026-09-23 23:12:40.563957');
INSERT INTO "ratings" VALUES(17,44,4,'2026-09-19 23:12:40.563957');
INSERT INTO "ratings" VALUES(12,44,2,'2026-09-10 23:12:40.563957');
INSERT INTO "ratings" VALUES(15,44,3,'2026-09-26 23:12:40.563957');
INSERT INTO "ratings" VALUES(18,44,5,'2026-09-22 23:12:40.563957');
INSERT INTO "ratings" VALUES(17,45,3,'2026-09-15 15:12:40.563957');
INSERT INTO "ratings" VALUES(5,45,4,'2026-09-26 15:12:40.563957');
INSERT INTO "ratings" VALUES(19,45,4,'2026-09-21 15:12:40.563957');
INSERT INTO "ratings" VALUES(3,45,4,'2026-09-13 15:12:40.563957');
INSERT INTO "ratings" VALUES(10,45,3,'2026-09-14 15:12:40.563957');
INSERT INTO "ratings" VALUES(18,46,5,'2026-09-18 11:12:40.563957');
INSERT INTO "ratings" VALUES(19,46,3,'2026-10-04 11:12:40.563957');
INSERT INTO "ratings" VALUES(10,46,3,'2026-10-05 11:12:40.563957');
INSERT INTO "ratings" VALUES(21,47,4,'2026-09-19 11:12:40.563957');
INSERT INTO "ratings" VALUES(5,47,4,'2026-09-26 11:12:40.563957');
INSERT INTO "ratings" VALUES(15,47,3,'2026-09-20 11:12:40.563957');
INSERT INTO "ratings" VALUES(4,47,4,'2026-09-24 11:12:40.563957');
INSERT INTO "ratings" VALUES(21,48,3,'2026-10-12 03:12:40.563957');
INSERT INTO "ratings" VALUES(16,48,3,'2026-09-23 03:12:40.563957');
INSERT INTO "ratings" VALUES(5,48,5,'2026-09-30 03:12:40.563957');
INSERT INTO "ratings" VALUES(3,48,3,'2026-10-02 03:12:40.563957');
INSERT INTO "ratings" VALUES(20,49,4,'2026-10-06 02:12:40.563957');
INSERT INTO "ratings" VALUES(3,49,4,'2026-10-04 02:12:40.563957');
INSERT INTO "ratings" VALUES(21,49,4,'2026-10-15 02:12:40.563957');
INSERT INTO "ratings" VALUES(16,49,2,'2026-10-15 02:12:40.563957');
INSERT INTO "ratings" VALUES(10,49,3,'2026-10-12 02:12:40.563957');
INSERT INTO "ratings" VALUES(18,49,5,'2026-10-05 02:12:40.563957');
INSERT INTO "ratings" VALUES(19,50,3,'2026-10-09 12:12:40.563957');
INSERT INTO "ratings" VALUES(12,50,5,'2026-10-06 12:12:40.563957');
INSERT INTO "ratings" VALUES(11,50,5,'2026-09-30 12:12:40.563957');
INSERT INTO "ratings" VALUES(17,50,5,'2026-10-08 12:12:40.563957');
INSERT INTO "ratings" VALUES(16,51,2,'2026-09-30 16:12:40.563957');
INSERT INTO "ratings" VALUES(17,51,3,'2026-10-01 16:12:40.563957');
INSERT INTO "ratings" VALUES(21,51,4,'2026-10-01 16:12:40.563957');
INSERT INTO "ratings" VALUES(4,51,4,'2026-10-06 16:12:40.563957');
INSERT INTO "ratings" VALUES(5,52,5,'2026-10-13 04:12:40.563957');
INSERT INTO "ratings" VALUES(11,52,5,'2026-10-07 04:12:40.563957');
INSERT INTO "ratings" VALUES(14,53,4,'2026-10-12 22:12:40.563957');
INSERT INTO "ratings" VALUES(10,53,5,'2026-10-24 22:12:40.563957');
INSERT INTO "ratings" VALUES(19,53,3,'2026-10-08 22:12:40.563957');
INSERT INTO "ratings" VALUES(18,53,3,'2026-10-10 22:12:40.563957');
INSERT INTO "ratings" VALUES(17,53,5,'2026-10-11 22:12:40.563957');
INSERT INTO "ratings" VALUES(11,53,5,'2026-10-23 22:12:40.563957');
INSERT INTO "ratings" VALUES(10,54,5,'2026-10-29 06:12:40.563957');
INSERT INTO "ratings" VALUES(21,54,4,'2026-10-15 06:12:40.563957');
INSERT INTO "ratings" VALUES(10,55,4,'2026-10-27 13:12:40.563957');
INSERT INTO "ratings" VALUES(5,55,5,'2026-10-18 13:12:40.563957');
INSERT INTO "ratings" VALUES(3,55,3,'2026-10-20 13:12:40.563957');
INSERT INTO "ratings" VALUES(11,55,4,'2026-10-25 13:12:40.563957');
INSERT INTO "ratings" VALUES(4,55,4,'2026-10-17 13:12:40.563957');
INSERT INTO "ratings" VALUES(18,55,4,'2026-10-13 13:12:40.563957');
INSERT INTO "ratings" VALUES(13,55,4,'2026-10-27 13:12:40.563957');
INSERT INTO "ratings" VALUES(13,56,3,'2026-10-20 05:12:40.563957');
INSERT INTO "ratings" VALUES(5,56,5,'2026-10-31 05:12:40.563957');
INSERT INTO "ratings" VALUES(12,56,4,'2026-10-21 05:12:40.563957');
INSERT INTO "ratings" VALUES(11,58,3,'2026-11-07 03:12:40.563957');
INSERT INTO "ratings" VALUES(21,58,3,'2026-10-29 03:12:40.563957');
INSERT INTO "ratings" VALUES(4,59,3,'2026-11-06 14:12:40.563957');
INSERT INTO "ratings" VALUES(12,59,3,'2026-11-12 14:12:40.563957');
INSERT INTO "ratings" VALUES(10,59,4,'2026-11-05 14:12:40.563957');
INSERT INTO "ratings" VALUES(16,59,4,'2026-11-07 14:12:40.563957');
INSERT INTO "ratings" VALUES(18,59,5,'2026-11-13 14:12:40.563957');
INSERT INTO "ratings" VALUES(20,59,4,'2026-11-01 14:12:40.563957');
INSERT INTO "ratings" VALUES(10,60,4,'2026-11-09 23:12:40.563957');
INSERT INTO "ratings" VALUES(3,60,3,'2026-11-06 23:12:40.563957');
CREATE TABLE reports (
	id INTEGER NOT NULL, 
	reporter_id INTEGER, 
	target_type VARCHAR(20) NOT NULL, 
	target_id INTEGER NOT NULL, 
	reason VARCHAR(500) NOT NULL, 
	status VARCHAR(20) NOT NULL, 
	resolution_note VARCHAR(500) NOT NULL, 
	handled_by_id INTEGER, 
	handled_at DATETIME, 
	created_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(reporter_id) REFERENCES users (id) ON DELETE SET NULL, 
	FOREIGN KEY(handled_by_id) REFERENCES users (id) ON DELETE SET NULL
);
INSERT INTO "reports" VALUES(1,10,'comment',130,'Insulting other readers','open','',NULL,NULL,'2026-10-31 00:12:40.563957');
INSERT INTO "reports" VALUES(2,15,'document',7,'One of the figures seems out of date, please double-check.','open','',NULL,NULL,'2026-10-30 07:12:40.563957');
CREATE TABLE role_permissions (
	role_id INTEGER NOT NULL, 
	permission_id INTEGER NOT NULL, 
	PRIMARY KEY (role_id, permission_id), 
	FOREIGN KEY(role_id) REFERENCES roles (id) ON DELETE CASCADE, 
	FOREIGN KEY(permission_id) REFERENCES permissions (id) ON DELETE CASCADE
);
INSERT INTO "role_permissions" VALUES(1,1);
INSERT INTO "role_permissions" VALUES(1,2);
INSERT INTO "role_permissions" VALUES(1,3);
INSERT INTO "role_permissions" VALUES(1,4);
INSERT INTO "role_permissions" VALUES(1,5);
INSERT INTO "role_permissions" VALUES(1,6);
INSERT INTO "role_permissions" VALUES(1,7);
INSERT INTO "role_permissions" VALUES(1,8);
INSERT INTO "role_permissions" VALUES(1,9);
INSERT INTO "role_permissions" VALUES(1,10);
INSERT INTO "role_permissions" VALUES(1,11);
INSERT INTO "role_permissions" VALUES(3,8);
INSERT INTO "role_permissions" VALUES(3,9);
INSERT INTO "role_permissions" VALUES(4,10);
INSERT INTO "role_permissions" VALUES(4,11);
INSERT INTO "role_permissions" VALUES(2,5);
INSERT INTO "role_permissions" VALUES(2,6);
INSERT INTO "role_permissions" VALUES(2,7);
CREATE TABLE roles (
	id INTEGER NOT NULL, 
	name VARCHAR(50) NOT NULL, 
	label VARCHAR(80) NOT NULL, 
	description VARCHAR(255) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
INSERT INTO "roles" VALUES(1,'super_admin','Super Admin','Manages users, roles and permissions, system logs and global settings.');
INSERT INTO "roles" VALUES(2,'content_manager','Content Manager','Full CRUD on content, publication status and taxonomy.');
INSERT INTO "roles" VALUES(3,'moderator','Moderator','Reviews user comments, handles reports and controls spam.');
INSERT INTO "roles" VALUES(4,'seo_specialist','Data & SEO Specialist','Configures SEO metadata and monitors analytics.');
INSERT INTO "roles" VALUES(5,'user','Member','Registered reader: profile, comments, likes, ratings and mentions.');
CREATE TABLE search_click_logs (
	id INTEGER NOT NULL, 
	event_type VARCHAR(10) NOT NULL, 
	user_id INTEGER, 
	session_id VARCHAR(64), 
	query_string VARCHAR(500) NOT NULL, 
	filters JSON, 
	results_count INTEGER, 
	search_id INTEGER, 
	clicked_doc_id INTEGER, 
	click_rank INTEGER, 
	timestamp DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE SET NULL, 
	FOREIGN KEY(search_id) REFERENCES search_click_logs (id) ON DELETE SET NULL, 
	FOREIGN KEY(clicked_doc_id) REFERENCES documents (id) ON DELETE SET NULL
);
INSERT INTO "search_click_logs" VALUES(1,'search',NULL,'seed-c1e07bf820f6','antibiotics','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-30 06:34:40.563957');
INSERT INTO "search_click_logs" VALUES(2,'click',NULL,'seed-c1e07bf820f6','antibiotics','{"sort": "relevance", "page": 1}',NULL,1,32,1,'2026-10-30 06:36:07.563957');
INSERT INTO "search_click_logs" VALUES(3,'search',9,'seed-10f50b147f1f','vaccine','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-31 03:09:40.563957');
INSERT INTO "search_click_logs" VALUES(4,'click',9,'seed-10f50b147f1f','vaccine','{"sort": "relevance", "page": 1}',NULL,3,4,1,'2026-10-31 03:09:58.563957');
INSERT INTO "search_click_logs" VALUES(5,'search',6,'seed-59feabac7bf8','cash flow','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-28 00:23:40.563957');
INSERT INTO "search_click_logs" VALUES(6,'click',6,'seed-59feabac7bf8','cash flow','{"sort": "relevance", "page": 1}',NULL,5,42,2,'2026-10-28 00:24:18.563957');
INSERT INTO "search_click_logs" VALUES(7,'search',17,'seed-ba82c7e2a618','misinformation','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-24 01:44:40.563957');
INSERT INTO "search_click_logs" VALUES(8,'click',17,'seed-ba82c7e2a618','misinformation','{"sort": "relevance", "page": 1}',NULL,7,8,1,'2026-10-24 01:45:57.563957');
INSERT INTO "search_click_logs" VALUES(9,'search',10,'seed-e6d32bf95861','antibiotics','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-18 00:40:40.563957');
INSERT INTO "search_click_logs" VALUES(10,'search',17,'seed-b52fd9ee9678','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-11 23:54:40.563957');
INSERT INTO "search_click_logs" VALUES(11,'click',17,'seed-b52fd9ee9678','passkeys','{"sort": "relevance", "page": 1}',NULL,10,27,1,'2026-10-11 23:56:09.563957');
INSERT INTO "search_click_logs" VALUES(12,'search',13,'seed-36da6c914882','quantum computing','{"sort": "relevance", "page": 1}',0,NULL,NULL,NULL,'2026-10-27 19:06:40.563957');
INSERT INTO "search_click_logs" VALUES(13,'search',4,'seed-1c3d77455560','coral reef','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-21 20:29:40.563957');
INSERT INTO "search_click_logs" VALUES(14,'click',4,'seed-1c3d77455560','coral reef','{"sort": "relevance", "page": 1}',NULL,13,46,1,'2026-10-21 20:30:19.563957');
INSERT INTO "search_click_logs" VALUES(15,'search',16,'seed-62811d9fff25','emergency fund','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-30 20:01:40.563957');
INSERT INTO "search_click_logs" VALUES(16,'click',16,'seed-62811d9fff25','emergency fund','{"sort": "relevance", "page": 1}',NULL,15,38,1,'2026-10-30 20:02:39.563957');
INSERT INTO "search_click_logs" VALUES(17,'search',7,'seed-11d1db558642','compound interest','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-21 16:36:40.563957');
INSERT INTO "search_click_logs" VALUES(18,'search',6,'seed-ffac0345eeda','electric cars','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-03 18:40:40.563957');
INSERT INTO "search_click_logs" VALUES(19,'click',6,'seed-ffac0345eeda','electric cars','{"sort": "relevance", "page": 1}',NULL,18,33,1,'2026-10-03 18:41:49.563957');
INSERT INTO "search_click_logs" VALUES(20,'search',13,'seed-b1ed668f5032','ocean','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-30 02:19:40.563957');
INSERT INTO "search_click_logs" VALUES(21,'click',13,'seed-b1ed668f5032','ocean','{"sort": "relevance", "page": 1}',NULL,20,46,3,'2026-10-30 02:20:04.563957');
INSERT INTO "search_click_logs" VALUES(22,'search',7,'seed-d812984f5a56','password','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-01 19:39:40.563957');
INSERT INTO "search_click_logs" VALUES(23,'search',9,'seed-b6a7c3cb0c28','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-07 14:10:40.563957');
INSERT INTO "search_click_logs" VALUES(24,'search',13,'seed-79cf5b29317a','blood pressure','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-10 09:14:40.563957');
INSERT INTO "search_click_logs" VALUES(25,'click',13,'seed-79cf5b29317a','blood pressure','{"sort": "relevance", "page": 1}',NULL,24,26,2,'2026-10-10 09:15:48.563957');
INSERT INTO "search_click_logs" VALUES(26,'click',13,'seed-79cf5b29317a','blood pressure','{"sort": "relevance", "page": 1}',NULL,24,2,1,'2026-10-10 09:15:41.563957');
INSERT INTO "search_click_logs" VALUES(27,'search',8,'seed-f141a0dcec7d','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-26 14:14:40.563957');
INSERT INTO "search_click_logs" VALUES(28,'click',8,'seed-f141a0dcec7d','heat pump','{"sort": "relevance", "page": 1}',NULL,27,15,1,'2026-10-26 14:14:51.563957');
INSERT INTO "search_click_logs" VALUES(29,'search',13,'seed-ade09ac60306','vaccine','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-31 01:06:40.563957');
INSERT INTO "search_click_logs" VALUES(30,'click',13,'seed-ade09ac60306','vaccine','{"sort": "relevance", "page": 1}',NULL,29,4,1,'2026-10-31 01:06:52.563957');
INSERT INTO "search_click_logs" VALUES(31,'search',NULL,'seed-33b1774d34f5','ocean','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-18 14:24:40.563957');
INSERT INTO "search_click_logs" VALUES(32,'click',NULL,'seed-33b1774d34f5','ocean','{"sort": "relevance", "page": 1}',NULL,31,13,1,'2026-10-18 14:25:52.563957');
INSERT INTO "search_click_logs" VALUES(33,'search',1,'seed-c393f3dc50bf','solar panels','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-06 12:33:40.563957');
INSERT INTO "search_click_logs" VALUES(34,'click',1,'seed-c393f3dc50bf','solar panels','{"sort": "relevance", "page": 1}',NULL,33,9,1,'2026-10-06 12:34:32.563957');
INSERT INTO "search_click_logs" VALUES(35,'search',15,'seed-086909360f02','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-06 16:06:40.563957');
INSERT INTO "search_click_logs" VALUES(36,'click',15,'seed-086909360f02','spaced repetition','{"sort": "relevance", "page": 1}',NULL,35,40,2,'2026-10-06 16:07:04.563957');
INSERT INTO "search_click_logs" VALUES(37,'search',16,'seed-1c00c3963bf9','vaccine','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-28 17:56:40.563957');
INSERT INTO "search_click_logs" VALUES(38,'click',16,'seed-1c00c3963bf9','vaccine','{"sort": "relevance", "page": 1}',NULL,37,4,1,'2026-10-28 17:57:52.563957');
INSERT INTO "search_click_logs" VALUES(39,'search',17,'seed-64310e44c9dc','exercise','{"sort": "relevance", "page": 1}',5,NULL,NULL,NULL,'2026-10-20 01:52:40.563957');
INSERT INTO "search_click_logs" VALUES(40,'click',17,'seed-64310e44c9dc','exercise','{"sort": "relevance", "page": 1}',NULL,39,21,1,'2026-10-20 01:54:09.563957');
INSERT INTO "search_click_logs" VALUES(41,'search',2,'seed-97280734a403','solar panels','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-01 20:16:40.563957');
INSERT INTO "search_click_logs" VALUES(42,'click',2,'seed-97280734a403','solar panels','{"sort": "relevance", "page": 1}',NULL,41,9,1,'2026-10-01 20:17:57.563957');
INSERT INTO "search_click_logs" VALUES(43,'click',2,'seed-97280734a403','solar panels','{"sort": "relevance", "page": 1}',NULL,41,9,1,'2026-10-01 20:18:03.563957');
INSERT INTO "search_click_logs" VALUES(44,'search',12,'seed-59ec697437ea','solar panels','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-29 19:26:40.563957');
INSERT INTO "search_click_logs" VALUES(45,'click',12,'seed-59ec697437ea','solar panels','{"sort": "relevance", "page": 1}',NULL,44,9,1,'2026-10-29 19:27:22.563957');
INSERT INTO "search_click_logs" VALUES(46,'search',10,'seed-566c1d4dfdb1','blood pressure','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-05 04:58:40.563957');
INSERT INTO "search_click_logs" VALUES(47,'click',10,'seed-566c1d4dfdb1','blood pressure','{"sort": "relevance", "page": 1}',NULL,46,2,1,'2026-10-05 05:00:07.563957');
INSERT INTO "search_click_logs" VALUES(48,'search',9,'seed-b22a05391557','fibre','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-16 16:50:40.563957');
INSERT INTO "search_click_logs" VALUES(49,'click',9,'seed-b22a05391557','fibre','{"sort": "relevance", "page": 1}',NULL,48,24,1,'2026-10-16 16:51:56.563957');
INSERT INTO "search_click_logs" VALUES(50,'search',4,'seed-acd4b0dc75fb','inflation','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-16 14:32:40.563957');
INSERT INTO "search_click_logs" VALUES(51,'click',4,'seed-acd4b0dc75fb','inflation','{"sort": "relevance", "page": 1}',NULL,50,60,2,'2026-10-16 14:34:08.563957');
INSERT INTO "search_click_logs" VALUES(52,'search',14,'seed-7f3833a67403','solar panels','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-15 18:48:40.563957');
INSERT INTO "search_click_logs" VALUES(53,'click',14,'seed-7f3833a67403','solar panels','{"sort": "relevance", "page": 1}',NULL,52,9,1,'2026-10-15 18:49:51.563957');
INSERT INTO "search_click_logs" VALUES(54,'click',14,'seed-7f3833a67403','solar panels','{"sort": "relevance", "page": 1}',NULL,52,9,1,'2026-10-15 18:49:16.563957');
INSERT INTO "search_click_logs" VALUES(55,'search',NULL,'seed-9fe339d3a9cf','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-01 17:29:40.563957');
INSERT INTO "search_click_logs" VALUES(56,'search',19,'seed-45fb563b04fa','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-07 03:58:40.563957');
INSERT INTO "search_click_logs" VALUES(57,'click',19,'seed-45fb563b04fa','heat pump','{"sort": "relevance", "page": 1}',NULL,56,15,1,'2026-10-07 03:59:09.563957');
INSERT INTO "search_click_logs" VALUES(58,'click',19,'seed-45fb563b04fa','heat pump','{"sort": "relevance", "page": 1}',NULL,56,15,1,'2026-10-07 03:58:52.563957');
INSERT INTO "search_click_logs" VALUES(59,'search',14,'seed-8a3aa9d84c4f','ocean','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-24 20:58:40.563957');
INSERT INTO "search_click_logs" VALUES(60,'click',14,'seed-8a3aa9d84c4f','ocean','{"sort": "relevance", "page": 1}',NULL,59,13,1,'2026-10-24 20:59:48.563957');
INSERT INTO "search_click_logs" VALUES(61,'search',1,'seed-b40da0ba6142','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-10 01:03:40.563957');
INSERT INTO "search_click_logs" VALUES(62,'click',1,'seed-b40da0ba6142','spaced repetition','{"sort": "relevance", "page": 1}',NULL,61,19,1,'2026-10-10 01:05:07.563957');
INSERT INTO "search_click_logs" VALUES(63,'search',9,'seed-a34fefe9e8c9','quantum computing','{"sort": "relevance", "page": 1}',0,NULL,NULL,NULL,'2026-10-10 15:15:40.563957');
INSERT INTO "search_click_logs" VALUES(64,'search',19,'seed-a073ba0371f9','emergency fund','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-15 16:24:40.563957');
INSERT INTO "search_click_logs" VALUES(65,'click',19,'seed-a073ba0371f9','emergency fund','{"sort": "relevance", "page": 1}',NULL,64,38,1,'2026-10-15 16:25:13.563957');
INSERT INTO "search_click_logs" VALUES(66,'search',14,'seed-51936906d118','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-12 20:58:40.563957');
INSERT INTO "search_click_logs" VALUES(67,'search',9,'seed-497bd2deb47d','startup','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-14 17:08:40.563957');
INSERT INTO "search_click_logs" VALUES(68,'click',9,'seed-497bd2deb47d','startup','{"sort": "relevance", "page": 1}',NULL,67,50,1,'2026-10-14 17:09:34.563957');
INSERT INTO "search_click_logs" VALUES(69,'search',8,'seed-d3c5cc0b200d','compound interest','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-29 06:16:40.563957');
INSERT INTO "search_click_logs" VALUES(70,'click',8,'seed-d3c5cc0b200d','compound interest','{"sort": "relevance", "page": 1}',NULL,69,60,1,'2026-10-29 06:17:37.563957');
INSERT INTO "search_click_logs" VALUES(71,'search',9,'seed-077522ed1e25','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-31 01:46:40.563957');
INSERT INTO "search_click_logs" VALUES(72,'click',9,'seed-077522ed1e25','climate','{"sort": "relevance", "page": 1}',NULL,71,45,4,'2026-10-31 01:47:05.563957');
INSERT INTO "search_click_logs" VALUES(73,'click',9,'seed-077522ed1e25','climate','{"sort": "relevance", "page": 1}',NULL,71,45,4,'2026-10-31 01:46:48.563957');
INSERT INTO "search_click_logs" VALUES(74,'search',2,'seed-e581dc0db266','quantum computing','{"sort": "relevance", "page": 1}',0,NULL,NULL,NULL,'2026-10-20 06:32:40.563957');
INSERT INTO "search_click_logs" VALUES(75,'search',14,'seed-5d0ae592ee7c','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-16 05:02:40.563957');
INSERT INTO "search_click_logs" VALUES(76,'click',14,'seed-5d0ae592ee7c','heat pump','{"sort": "relevance", "page": 1}',NULL,75,15,1,'2026-10-16 05:03:00.563957');
INSERT INTO "search_click_logs" VALUES(77,'click',14,'seed-5d0ae592ee7c','heat pump','{"sort": "relevance", "page": 1}',NULL,75,15,1,'2026-10-16 05:03:56.563957');
INSERT INTO "search_click_logs" VALUES(78,'search',NULL,'seed-9496d438231d','language learning','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-03 13:24:40.563957');
INSERT INTO "search_click_logs" VALUES(79,'search',8,'seed-1f4d998de3d8','cash flow','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-27 04:08:40.563957');
INSERT INTO "search_click_logs" VALUES(80,'search',NULL,'seed-be74bf957403','recycling','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-07 17:54:40.563957');
INSERT INTO "search_click_logs" VALUES(81,'click',NULL,'seed-be74bf957403','recycling','{"sort": "relevance", "page": 1}',NULL,80,39,1,'2026-10-07 17:55:05.563957');
INSERT INTO "search_click_logs" VALUES(82,'search',9,'seed-96e8dce70289','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-25 17:16:40.563957');
INSERT INTO "search_click_logs" VALUES(83,'click',9,'seed-96e8dce70289','phishing','{"sort": "relevance", "page": 1}',NULL,82,27,2,'2026-10-25 17:16:57.563957');
INSERT INTO "search_click_logs" VALUES(84,'search',8,'seed-4719f69bd596','recycling','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-21 07:54:40.563957');
INSERT INTO "search_click_logs" VALUES(85,'search',NULL,'seed-05654ee45227','misinformation','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-22 18:39:40.563957');
INSERT INTO "search_click_logs" VALUES(86,'click',NULL,'seed-05654ee45227','misinformation','{"sort": "relevance", "page": 1}',NULL,85,8,1,'2026-10-22 18:41:07.563957');
INSERT INTO "search_click_logs" VALUES(87,'click',NULL,'seed-05654ee45227','misinformation','{"sort": "relevance", "page": 1}',NULL,85,8,1,'2026-10-22 18:39:49.563957');
INSERT INTO "search_click_logs" VALUES(88,'search',9,'seed-627b8d7f9371','salary','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-08 23:02:40.563957');
INSERT INTO "search_click_logs" VALUES(89,'click',9,'seed-627b8d7f9371','salary','{"sort": "relevance", "page": 1}',NULL,88,57,1,'2026-10-08 23:04:10.563957');
INSERT INTO "search_click_logs" VALUES(90,'click',9,'seed-627b8d7f9371','salary','{"sort": "relevance", "page": 1}',NULL,88,57,1,'2026-10-08 23:03:13.563957');
INSERT INTO "search_click_logs" VALUES(91,'search',9,'seed-171a4d07018b','fibre','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-22 17:48:40.563957');
INSERT INTO "search_click_logs" VALUES(92,'search',15,'seed-5132a1a054a9','antibiotics','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-25 01:44:40.563957');
INSERT INTO "search_click_logs" VALUES(93,'search',9,'seed-1481ddcf5003','bees','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-22 06:03:40.563957');
INSERT INTO "search_click_logs" VALUES(94,'search',NULL,'seed-b7a6552d4865','misinformation','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-19 17:07:40.563957');
INSERT INTO "search_click_logs" VALUES(95,'click',NULL,'seed-b7a6552d4865','misinformation','{"sort": "relevance", "page": 1}',NULL,94,8,1,'2026-10-19 17:08:03.563957');
INSERT INTO "search_click_logs" VALUES(96,'click',NULL,'seed-b7a6552d4865','misinformation','{"sort": "relevance", "page": 1}',NULL,94,8,1,'2026-10-19 17:08:47.563957');
INSERT INTO "search_click_logs" VALUES(97,'search',NULL,'seed-740853a71719','password','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-21 12:31:40.563957');
INSERT INTO "search_click_logs" VALUES(98,'click',NULL,'seed-740853a71719','password','{"sort": "relevance", "page": 1}',NULL,97,53,2,'2026-10-21 12:32:06.563957');
INSERT INTO "search_click_logs" VALUES(99,'search',1,'seed-33386691c664','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-09 02:34:40.563957');
INSERT INTO "search_click_logs" VALUES(100,'click',1,'seed-33386691c664','climate','{"sort": "relevance", "page": 1}',NULL,99,13,1,'2026-10-09 02:35:03.563957');
INSERT INTO "search_click_logs" VALUES(101,'search',NULL,'seed-d8d2214dc588','compound interest','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-11 09:03:40.563957');
INSERT INTO "search_click_logs" VALUES(102,'click',NULL,'seed-d8d2214dc588','compound interest','{"sort": "relevance", "page": 1}',NULL,101,60,1,'2026-10-11 09:04:40.563957');
INSERT INTO "search_click_logs" VALUES(103,'search',6,'seed-97d0affdd43b','battery','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-10 22:19:40.563957');
INSERT INTO "search_click_logs" VALUES(104,'search',12,'seed-64bc2e904b5c','electric cars','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-27 17:04:40.563957');
INSERT INTO "search_click_logs" VALUES(105,'search',1,'seed-05e1f2b74922','misinformation','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-05 23:33:40.563957');
INSERT INTO "search_click_logs" VALUES(106,'search',15,'seed-430432c192f1','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-15 04:10:40.563957');
INSERT INTO "search_click_logs" VALUES(107,'click',15,'seed-430432c192f1','climate','{"sort": "relevance", "page": 1}',NULL,106,48,2,'2026-10-15 04:11:37.563957');
INSERT INTO "search_click_logs" VALUES(108,'search',6,'seed-9136f27e8ce7','blood pressure','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-28 18:39:40.563957');
INSERT INTO "search_click_logs" VALUES(109,'click',6,'seed-9136f27e8ce7','blood pressure','{"sort": "relevance", "page": 1}',NULL,108,2,1,'2026-10-28 18:40:41.563957');
INSERT INTO "search_click_logs" VALUES(110,'search',NULL,'seed-30c7340155bd','stress','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-19 23:33:40.563957');
INSERT INTO "search_click_logs" VALUES(111,'search',13,'seed-6e6a2154be4a','stress','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-25 14:20:40.563957');
INSERT INTO "search_click_logs" VALUES(112,'search',NULL,'seed-307aad5c3c49','blood pressure','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-01 21:33:40.563957');
INSERT INTO "search_click_logs" VALUES(113,'click',NULL,'seed-307aad5c3c49','blood pressure','{"sort": "relevance", "page": 1}',NULL,112,2,1,'2026-10-01 21:34:20.563957');
INSERT INTO "search_click_logs" VALUES(114,'search',8,'seed-95395ea0942c','blockchain','{"sort": "relevance", "page": 1}',0,NULL,NULL,NULL,'2026-10-26 15:49:40.563957');
INSERT INTO "search_click_logs" VALUES(115,'search',16,'seed-df162219b7f7','gps','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-21 06:51:40.563957');
INSERT INTO "search_click_logs" VALUES(116,'click',16,'seed-df162219b7f7','gps','{"sort": "relevance", "page": 1}',NULL,115,31,1,'2026-10-21 06:52:32.563957');
INSERT INTO "search_click_logs" VALUES(117,'search',3,'seed-8e9718643b6a','salary','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-10 22:28:40.563957');
INSERT INTO "search_click_logs" VALUES(118,'click',3,'seed-8e9718643b6a','salary','{"sort": "relevance", "page": 1}',NULL,117,57,1,'2026-10-10 22:29:28.563957');
INSERT INTO "search_click_logs" VALUES(119,'search',NULL,'seed-cf52bf8cc6f9','vitamin d','{"sort": "relevance", "page": 1}',0,NULL,NULL,NULL,'2026-10-03 10:47:40.563957');
INSERT INTO "search_click_logs" VALUES(120,'search',13,'seed-fa3f4d711f28','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-25 10:03:40.563957');
INSERT INTO "search_click_logs" VALUES(121,'click',13,'seed-fa3f4d711f28','passkeys','{"sort": "relevance", "page": 1}',NULL,120,20,3,'2026-10-25 10:04:54.563957');
INSERT INTO "search_click_logs" VALUES(122,'search',17,'seed-ee297e2ac03a','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-28 01:25:40.563957');
INSERT INTO "search_click_logs" VALUES(123,'click',17,'seed-ee297e2ac03a','passkeys','{"sort": "relevance", "page": 1}',NULL,122,27,1,'2026-10-28 01:26:50.563957');
INSERT INTO "search_click_logs" VALUES(124,'search',2,'seed-20bcfa801062','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-25 20:31:40.563957');
INSERT INTO "search_click_logs" VALUES(125,'click',2,'seed-20bcfa801062','spaced repetition','{"sort": "relevance", "page": 1}',NULL,124,19,1,'2026-10-25 20:32:29.563957');
INSERT INTO "search_click_logs" VALUES(126,'click',2,'seed-20bcfa801062','spaced repetition','{"sort": "relevance", "page": 1}',NULL,124,40,2,'2026-10-25 20:32:19.563957');
INSERT INTO "search_click_logs" VALUES(127,'search',17,'seed-6f8e502171bd','startup','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-25 22:12:40.563957');
INSERT INTO "search_click_logs" VALUES(128,'search',18,'seed-ec40da6069f3','recycling','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-02 02:03:40.563957');
INSERT INTO "search_click_logs" VALUES(129,'click',18,'seed-ec40da6069f3','recycling','{"sort": "relevance", "page": 1}',NULL,128,39,1,'2026-10-02 02:04:02.563957');
INSERT INTO "search_click_logs" VALUES(130,'search',9,'seed-b4b929debccc','password','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-27 15:09:40.563957');
INSERT INTO "search_click_logs" VALUES(131,'click',9,'seed-b4b929debccc','password','{"sort": "relevance", "page": 1}',NULL,130,20,3,'2026-10-27 15:10:46.563957');
INSERT INTO "search_click_logs" VALUES(132,'search',16,'seed-7e34752fbd7e','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-23 12:04:40.563957');
INSERT INTO "search_click_logs" VALUES(133,'click',16,'seed-7e34752fbd7e','passkeys','{"sort": "relevance", "page": 1}',NULL,132,27,1,'2026-10-23 12:05:27.563957');
INSERT INTO "search_click_logs" VALUES(134,'search',NULL,'seed-bffb2b15619e','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-07 01:03:40.563957');
INSERT INTO "search_click_logs" VALUES(135,'click',NULL,'seed-bffb2b15619e','heat pump','{"sort": "relevance", "page": 1}',NULL,134,15,1,'2026-10-07 01:04:57.563957');
INSERT INTO "search_click_logs" VALUES(136,'search',17,'seed-921fc4502052','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-02 07:04:40.563957');
INSERT INTO "search_click_logs" VALUES(137,'click',17,'seed-921fc4502052','phishing','{"sort": "relevance", "page": 1}',NULL,136,53,1,'2026-10-02 07:05:46.563957');
INSERT INTO "search_click_logs" VALUES(138,'click',17,'seed-921fc4502052','phishing','{"sort": "relevance", "page": 1}',NULL,136,27,2,'2026-10-02 07:05:25.563957');
INSERT INTO "search_click_logs" VALUES(139,'search',4,'seed-5fa164e84ffc','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-12 07:59:40.563957');
INSERT INTO "search_click_logs" VALUES(140,'click',4,'seed-5fa164e84ffc','passkeys','{"sort": "relevance", "page": 1}',NULL,139,20,3,'2026-10-12 08:00:02.563957');
INSERT INTO "search_click_logs" VALUES(141,'click',4,'seed-5fa164e84ffc','passkeys','{"sort": "relevance", "page": 1}',NULL,139,27,1,'2026-10-12 08:00:41.563957');
INSERT INTO "search_click_logs" VALUES(142,'search',21,'seed-44f2f4881671','stress','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-13 15:43:40.563957');
INSERT INTO "search_click_logs" VALUES(143,'click',21,'seed-44f2f4881671','stress','{"sort": "relevance", "page": 1}',NULL,142,21,3,'2026-10-13 15:45:06.563957');
INSERT INTO "search_click_logs" VALUES(144,'search',5,'seed-dcff361c2373','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-20 11:47:40.563957');
INSERT INTO "search_click_logs" VALUES(145,'click',5,'seed-dcff361c2373','climate','{"sort": "relevance", "page": 1}',NULL,144,13,1,'2026-10-20 11:47:50.563957');
INSERT INTO "search_click_logs" VALUES(146,'search',13,'seed-661b17b16c43','language learning','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-17 10:39:40.563957');
INSERT INTO "search_click_logs" VALUES(147,'click',13,'seed-661b17b16c43','language learning','{"sort": "relevance", "page": 1}',NULL,146,40,1,'2026-10-17 10:40:34.563957');
INSERT INTO "search_click_logs" VALUES(148,'search',13,'seed-6703c78cd2c3','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-07 01:39:40.563957');
INSERT INTO "search_click_logs" VALUES(149,'click',13,'seed-6703c78cd2c3','heat pump','{"sort": "relevance", "page": 1}',NULL,148,15,1,'2026-10-07 01:39:58.563957');
INSERT INTO "search_click_logs" VALUES(150,'search',NULL,'seed-219c9a7fde23','crispr','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-08 20:37:40.563957');
INSERT INTO "search_click_logs" VALUES(151,'click',NULL,'seed-219c9a7fde23','crispr','{"sort": "relevance", "page": 1}',NULL,150,41,1,'2026-10-08 20:38:08.563957');
INSERT INTO "search_click_logs" VALUES(152,'search',9,'seed-99af90248225','vaccine','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-05 14:57:40.563957');
INSERT INTO "search_click_logs" VALUES(153,'click',9,'seed-99af90248225','vaccine','{"sort": "relevance", "page": 1}',NULL,152,56,2,'2026-10-05 14:59:01.563957');
INSERT INTO "search_click_logs" VALUES(154,'search',2,'seed-577c836a5887','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-15 04:02:40.563957');
INSERT INTO "search_click_logs" VALUES(155,'search',16,'seed-a12a86fbbcdb','gps','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-14 01:55:40.563957');
INSERT INTO "search_click_logs" VALUES(156,'click',16,'seed-a12a86fbbcdb','gps','{"sort": "relevance", "page": 1}',NULL,155,31,1,'2026-10-14 01:55:53.563957');
INSERT INTO "search_click_logs" VALUES(157,'search',5,'seed-e724af2f32a7','startup','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-20 02:08:40.563957');
INSERT INTO "search_click_logs" VALUES(158,'click',5,'seed-e724af2f32a7','startup','{"sort": "relevance", "page": 1}',NULL,157,50,1,'2026-10-20 02:09:55.563957');
INSERT INTO "search_click_logs" VALUES(159,'search',17,'seed-82ba1b8dc821','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-30 05:40:40.563957');
INSERT INTO "search_click_logs" VALUES(160,'click',17,'seed-82ba1b8dc821','passkeys','{"sort": "relevance", "page": 1}',NULL,159,53,2,'2026-10-30 05:41:55.563957');
INSERT INTO "search_click_logs" VALUES(161,'search',3,'seed-80e1c4c608eb','stress','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-23 11:13:40.563957');
INSERT INTO "search_click_logs" VALUES(162,'click',3,'seed-80e1c4c608eb','stress','{"sort": "relevance", "page": 1}',NULL,161,26,1,'2026-10-23 11:14:06.563957');
INSERT INTO "search_click_logs" VALUES(163,'search',NULL,'seed-505e4c32a0a2','note taking','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-30 17:00:40.563957');
INSERT INTO "search_click_logs" VALUES(164,'click',NULL,'seed-505e4c32a0a2','note taking','{"sort": "relevance", "page": 1}',NULL,163,3,1,'2026-10-30 17:02:02.563957');
INSERT INTO "search_click_logs" VALUES(165,'search',7,'seed-14062f61e334','electric cars','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-24 00:49:40.563957');
INSERT INTO "search_click_logs" VALUES(166,'search',14,'seed-049688ccddbc','blood pressure','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-06 03:35:40.563957');
INSERT INTO "search_click_logs" VALUES(167,'click',14,'seed-049688ccddbc','blood pressure','{"sort": "relevance", "page": 1}',NULL,166,2,1,'2026-10-06 03:36:44.563957');
INSERT INTO "search_click_logs" VALUES(168,'search',NULL,'seed-b9d59a154b85','battery','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-21 08:45:40.563957');
INSERT INTO "search_click_logs" VALUES(169,'click',NULL,'seed-b9d59a154b85','battery','{"sort": "relevance", "page": 1}',NULL,168,9,3,'2026-10-21 08:46:29.563957');
INSERT INTO "search_click_logs" VALUES(170,'search',13,'seed-4d7acdfcef75','salary','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-02 08:10:40.563957');
INSERT INTO "search_click_logs" VALUES(171,'click',13,'seed-4d7acdfcef75','salary','{"sort": "relevance", "page": 1}',NULL,170,57,1,'2026-10-02 08:10:45.563957');
INSERT INTO "search_click_logs" VALUES(172,'search',7,'seed-a60c7b2a7f10','salary','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-28 06:18:40.563957');
INSERT INTO "search_click_logs" VALUES(173,'click',7,'seed-a60c7b2a7f10','salary','{"sort": "relevance", "page": 1}',NULL,172,57,1,'2026-10-28 06:19:51.563957');
INSERT INTO "search_click_logs" VALUES(174,'search',5,'seed-6c007957595f','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-24 15:23:40.563957');
INSERT INTO "search_click_logs" VALUES(175,'click',5,'seed-6c007957595f','phishing','{"sort": "relevance", "page": 1}',NULL,174,53,1,'2026-10-24 15:24:39.563957');
INSERT INTO "search_click_logs" VALUES(176,'search',19,'seed-338a3e1cfa14','quantum computing','{"sort": "relevance", "page": 1}',0,NULL,NULL,NULL,'2026-10-19 15:52:40.563957');
INSERT INTO "search_click_logs" VALUES(177,'search',2,'seed-020455773297','crispr','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-07 17:50:40.563957');
INSERT INTO "search_click_logs" VALUES(178,'click',2,'seed-020455773297','crispr','{"sort": "relevance", "page": 1}',NULL,177,41,1,'2026-10-07 17:51:36.563957');
INSERT INTO "search_click_logs" VALUES(179,'click',2,'seed-020455773297','crispr','{"sort": "relevance", "page": 1}',NULL,177,41,1,'2026-10-07 17:51:57.563957');
INSERT INTO "search_click_logs" VALUES(180,'search',2,'seed-66517ccc9258','blood pressure','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-17 21:17:40.563957');
INSERT INTO "search_click_logs" VALUES(181,'click',2,'seed-66517ccc9258','blood pressure','{"sort": "relevance", "page": 1}',NULL,180,2,1,'2026-10-17 21:19:09.563957');
INSERT INTO "search_click_logs" VALUES(182,'search',NULL,'seed-873f0f8a579c','startup','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-06 23:18:40.563957');
INSERT INTO "search_click_logs" VALUES(183,'click',NULL,'seed-873f0f8a579c','startup','{"sort": "relevance", "page": 1}',NULL,182,50,1,'2026-10-06 23:19:17.563957');
INSERT INTO "search_click_logs" VALUES(184,'search',4,'seed-9f697eaa7a91','tardigrade','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-21 15:03:40.563957');
INSERT INTO "search_click_logs" VALUES(185,'search',6,'seed-b9e849bb1313','solar panels','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-13 06:30:40.563957');
INSERT INTO "search_click_logs" VALUES(186,'click',6,'seed-b9e849bb1313','solar panels','{"sort": "relevance", "page": 1}',NULL,185,9,1,'2026-10-13 06:31:11.563957');
INSERT INTO "search_click_logs" VALUES(187,'search',NULL,'seed-a82eb7174acf','exercise','{"sort": "relevance", "page": 1}',5,NULL,NULL,NULL,'2026-10-12 10:39:40.563957');
INSERT INTO "search_click_logs" VALUES(188,'click',NULL,'seed-a82eb7174acf','exercise','{"sort": "relevance", "page": 1}',NULL,187,52,3,'2026-10-12 10:40:32.563957');
INSERT INTO "search_click_logs" VALUES(189,'click',NULL,'seed-a82eb7174acf','exercise','{"sort": "relevance", "page": 1}',NULL,187,2,5,'2026-10-12 10:41:09.563957');
INSERT INTO "search_click_logs" VALUES(190,'search',NULL,'seed-d833f88fa199','ocean','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-23 15:05:40.563957');
INSERT INTO "search_click_logs" VALUES(191,'click',NULL,'seed-d833f88fa199','ocean','{"sort": "relevance", "page": 1}',NULL,190,56,2,'2026-10-23 15:05:54.563957');
INSERT INTO "search_click_logs" VALUES(192,'search',6,'seed-7dff9b125dfb','ocean','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-29 00:24:40.563957');
INSERT INTO "search_click_logs" VALUES(193,'click',6,'seed-7dff9b125dfb','ocean','{"sort": "relevance", "page": 1}',NULL,192,46,3,'2026-10-29 00:25:21.563957');
INSERT INTO "search_click_logs" VALUES(194,'search',12,'seed-42c4e1831003','compound interest','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-17 06:35:40.563957');
INSERT INTO "search_click_logs" VALUES(195,'click',12,'seed-42c4e1831003','compound interest','{"sort": "relevance", "page": 1}',NULL,194,60,1,'2026-10-17 06:36:47.563957');
INSERT INTO "search_click_logs" VALUES(196,'search',4,'seed-3a089e189a98','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-30 16:31:40.563957');
INSERT INTO "search_click_logs" VALUES(197,'click',4,'seed-3a089e189a98','passkeys','{"sort": "relevance", "page": 1}',NULL,196,27,1,'2026-10-30 16:32:26.563957');
INSERT INTO "search_click_logs" VALUES(198,'search',9,'seed-26b3e57513a5','electric cars','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-09 12:12:40.563957');
INSERT INTO "search_click_logs" VALUES(199,'search',NULL,'seed-ed370ce87570','hydration','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-16 03:39:40.563957');
INSERT INTO "search_click_logs" VALUES(200,'search',4,'seed-9c4ec81a5f0f','electric cars','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-03 03:25:40.563957');
INSERT INTO "search_click_logs" VALUES(201,'click',4,'seed-9c4ec81a5f0f','electric cars','{"sort": "relevance", "page": 1}',NULL,200,33,1,'2026-10-03 03:26:54.563957');
INSERT INTO "search_click_logs" VALUES(202,'click',4,'seed-9c4ec81a5f0f','electric cars','{"sort": "relevance", "page": 1}',NULL,200,33,1,'2026-10-03 03:25:56.563957');
INSERT INTO "search_click_logs" VALUES(203,'search',12,'seed-ba75283348ea','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-30 00:12:40.563957');
INSERT INTO "search_click_logs" VALUES(204,'click',12,'seed-ba75283348ea','sleep','{"sort": "relevance", "page": 1}',NULL,203,43,1,'2026-10-30 00:12:55.563957');
INSERT INTO "search_click_logs" VALUES(205,'search',4,'seed-33afd93d8722','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-23 02:30:40.563957');
INSERT INTO "search_click_logs" VALUES(206,'click',4,'seed-33afd93d8722','sleep','{"sort": "relevance", "page": 1}',NULL,205,34,3,'2026-10-23 02:31:14.563957');
INSERT INTO "search_click_logs" VALUES(207,'search',17,'seed-15d12bd7d038','stress','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-19 21:25:40.563957');
INSERT INTO "search_click_logs" VALUES(208,'click',17,'seed-15d12bd7d038','stress','{"sort": "relevance", "page": 1}',NULL,207,26,1,'2026-10-19 21:27:03.563957');
INSERT INTO "search_click_logs" VALUES(209,'search',14,'seed-3a6ac986f893','ocean','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-28 13:08:40.563957');
INSERT INTO "search_click_logs" VALUES(210,'click',14,'seed-3a6ac986f893','ocean','{"sort": "relevance", "page": 1}',NULL,209,46,3,'2026-10-28 13:09:41.563957');
INSERT INTO "search_click_logs" VALUES(211,'search',12,'seed-079ef198f62e','quantum computing','{"sort": "relevance", "page": 1}',0,NULL,NULL,NULL,'2026-10-18 07:55:40.563957');
INSERT INTO "search_click_logs" VALUES(212,'search',3,'seed-569b15b4066e','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-09 13:33:40.563957');
INSERT INTO "search_click_logs" VALUES(213,'click',3,'seed-569b15b4066e','spaced repetition','{"sort": "relevance", "page": 1}',NULL,212,19,1,'2026-10-09 13:33:50.563957');
INSERT INTO "search_click_logs" VALUES(214,'click',3,'seed-569b15b4066e','spaced repetition','{"sort": "relevance", "page": 1}',NULL,212,19,1,'2026-10-09 13:33:47.563957');
INSERT INTO "search_click_logs" VALUES(215,'search',2,'seed-a1b1fa4cb559','ocean','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-14 11:36:40.563957');
INSERT INTO "search_click_logs" VALUES(216,'search',14,'seed-e2c266e9a80e','electric cars','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-05 21:07:40.563957');
INSERT INTO "search_click_logs" VALUES(217,'click',14,'seed-e2c266e9a80e','electric cars','{"sort": "relevance", "page": 1}',NULL,216,33,1,'2026-10-05 21:08:23.563957');
INSERT INTO "search_click_logs" VALUES(218,'search',17,'seed-eba29c433e67','startup','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-30 21:40:40.563957');
INSERT INTO "search_click_logs" VALUES(219,'click',17,'seed-eba29c433e67','startup','{"sort": "relevance", "page": 1}',NULL,218,42,2,'2026-10-30 21:41:52.563957');
INSERT INTO "search_click_logs" VALUES(220,'search',NULL,'seed-e33e58625813','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-14 16:07:40.563957');
INSERT INTO "search_click_logs" VALUES(221,'search',3,'seed-89950976e09f','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-09 20:55:40.563957');
INSERT INTO "search_click_logs" VALUES(222,'click',3,'seed-89950976e09f','climate','{"sort": "relevance", "page": 1}',NULL,221,37,5,'2026-10-09 20:55:59.563957');
INSERT INTO "search_click_logs" VALUES(223,'search',3,'seed-8d4182fce908','coral reef','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-17 23:55:40.563957');
INSERT INTO "search_click_logs" VALUES(224,'click',3,'seed-8d4182fce908','coral reef','{"sort": "relevance", "page": 1}',NULL,223,46,1,'2026-10-17 23:55:45.563957');
INSERT INTO "search_click_logs" VALUES(225,'search',9,'seed-d50c3dc8719c','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-08 10:59:40.563957');
INSERT INTO "search_click_logs" VALUES(226,'search',NULL,'seed-d7720f589a93','remote work','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-02 03:26:40.563957');
INSERT INTO "search_click_logs" VALUES(227,'click',NULL,'seed-d7720f589a93','remote work','{"sort": "relevance", "page": 1}',NULL,226,14,1,'2026-10-02 03:26:49.563957');
INSERT INTO "search_click_logs" VALUES(228,'search',10,'seed-bca2928b1e4b','antibiotics','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-03 15:53:40.563957');
INSERT INTO "search_click_logs" VALUES(229,'click',10,'seed-bca2928b1e4b','antibiotics','{"sort": "relevance", "page": 1}',NULL,228,32,1,'2026-10-03 15:54:57.563957');
INSERT INTO "search_click_logs" VALUES(230,'search',NULL,'seed-d83088859ae5','exercise','{"sort": "relevance", "page": 1}',5,NULL,NULL,NULL,'2026-10-05 09:47:40.563957');
INSERT INTO "search_click_logs" VALUES(231,'click',NULL,'seed-d83088859ae5','exercise','{"sort": "relevance", "page": 1}',NULL,230,21,1,'2026-10-05 09:48:56.563957');
INSERT INTO "search_click_logs" VALUES(232,'search',NULL,'seed-1af03f64e5ee','gps','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-11 13:28:40.563957');
INSERT INTO "search_click_logs" VALUES(233,'click',NULL,'seed-1af03f64e5ee','gps','{"sort": "relevance", "page": 1}',NULL,232,31,1,'2026-10-11 13:29:29.563957');
INSERT INTO "search_click_logs" VALUES(234,'search',NULL,'seed-14fa697c4d7d','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-28 16:41:40.563957');
INSERT INTO "search_click_logs" VALUES(235,'click',NULL,'seed-14fa697c4d7d','spaced repetition','{"sort": "relevance", "page": 1}',NULL,234,19,1,'2026-10-28 16:42:10.563957');
INSERT INTO "search_click_logs" VALUES(236,'search',13,'seed-8f189696dc6c','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-22 13:15:40.563957');
INSERT INTO "search_click_logs" VALUES(237,'click',13,'seed-8f189696dc6c','spaced repetition','{"sort": "relevance", "page": 1}',NULL,236,19,1,'2026-10-22 13:16:46.563957');
INSERT INTO "search_click_logs" VALUES(238,'search',16,'seed-f928bb51cd74','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-01 07:41:40.563957');
INSERT INTO "search_click_logs" VALUES(239,'click',16,'seed-f928bb51cd74','climate','{"sort": "relevance", "page": 1}',NULL,238,46,3,'2026-10-01 07:42:45.563957');
INSERT INTO "search_click_logs" VALUES(240,'search',17,'seed-b1c81e390f21','remote work','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-28 13:41:40.563957');
INSERT INTO "search_click_logs" VALUES(241,'click',17,'seed-b1c81e390f21','remote work','{"sort": "relevance", "page": 1}',NULL,240,14,1,'2026-10-28 13:42:54.563957');
INSERT INTO "search_click_logs" VALUES(242,'search',14,'seed-1ef11c3efda4','inflation','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-02 10:40:40.563957');
INSERT INTO "search_click_logs" VALUES(243,'click',14,'seed-1ef11c3efda4','inflation','{"sort": "relevance", "page": 1}',NULL,242,25,1,'2026-10-02 10:40:58.563957');
INSERT INTO "search_click_logs" VALUES(244,'search',10,'seed-07297c659dc9','inflation','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-01 20:51:40.563957');
INSERT INTO "search_click_logs" VALUES(245,'search',10,'seed-4892e39940dd','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-16 05:33:40.563957');
INSERT INTO "search_click_logs" VALUES(246,'click',10,'seed-4892e39940dd','sleep','{"sort": "relevance", "page": 1}',NULL,245,43,1,'2026-10-16 05:33:58.563957');
INSERT INTO "search_click_logs" VALUES(247,'click',10,'seed-4892e39940dd','sleep','{"sort": "relevance", "page": 1}',NULL,245,6,2,'2026-10-16 05:33:51.563957');
INSERT INTO "search_click_logs" VALUES(248,'search',10,'seed-73ce90d5e87e','hydration','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-21 11:39:40.563957');
INSERT INTO "search_click_logs" VALUES(249,'search',5,'seed-2376c30f3c69','bees','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-19 10:32:40.563957');
INSERT INTO "search_click_logs" VALUES(250,'click',5,'seed-2376c30f3c69','bees','{"sort": "relevance", "page": 1}',NULL,249,48,1,'2026-10-19 10:33:40.563957');
INSERT INTO "search_click_logs" VALUES(251,'search',NULL,'seed-aa1c9ff0f466','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-12 04:10:40.563957');
INSERT INTO "search_click_logs" VALUES(252,'click',NULL,'seed-aa1c9ff0f466','sleep','{"sort": "relevance", "page": 1}',NULL,251,26,4,'2026-10-12 04:11:26.563957');
INSERT INTO "search_click_logs" VALUES(253,'search',NULL,'seed-a55a47020de0','emergency fund','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-02 16:05:40.563957');
INSERT INTO "search_click_logs" VALUES(254,'click',NULL,'seed-a55a47020de0','emergency fund','{"sort": "relevance", "page": 1}',NULL,253,38,1,'2026-10-02 16:07:03.563957');
INSERT INTO "search_click_logs" VALUES(255,'search',21,'seed-a4d71fb026cc','electric cars','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-11 12:03:40.563957');
INSERT INTO "search_click_logs" VALUES(256,'click',21,'seed-a4d71fb026cc','electric cars','{"sort": "relevance", "page": 1}',NULL,255,33,1,'2026-10-11 12:04:56.563957');
INSERT INTO "search_click_logs" VALUES(257,'search',7,'seed-79d0c0249b51','antibiotics','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-02 13:24:40.563957');
INSERT INTO "search_click_logs" VALUES(258,'click',7,'seed-79d0c0249b51','antibiotics','{"sort": "relevance", "page": 1}',NULL,257,32,1,'2026-10-02 13:25:51.563957');
INSERT INTO "search_click_logs" VALUES(259,'search',8,'seed-b4a3d4669984','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-31 00:11:40.563957');
INSERT INTO "search_click_logs" VALUES(260,'search',20,'seed-66dc5207c6cc','exercise','{"sort": "relevance", "page": 1}',5,NULL,NULL,NULL,'2026-10-29 13:00:40.563957');
INSERT INTO "search_click_logs" VALUES(261,'click',20,'seed-66dc5207c6cc','exercise','{"sort": "relevance", "page": 1}',NULL,260,2,5,'2026-10-29 13:01:26.563957');
INSERT INTO "search_click_logs" VALUES(262,'search',11,'seed-41d661cb78c3','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-21 13:11:40.563957');
INSERT INTO "search_click_logs" VALUES(263,'click',11,'seed-41d661cb78c3','spaced repetition','{"sort": "relevance", "page": 1}',NULL,262,19,1,'2026-10-21 13:12:19.563957');
INSERT INTO "search_click_logs" VALUES(264,'click',11,'seed-41d661cb78c3','spaced repetition','{"sort": "relevance", "page": 1}',NULL,262,19,1,'2026-10-21 13:12:15.563957');
INSERT INTO "search_click_logs" VALUES(265,'search',NULL,'seed-0f142b501ad7','bees','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-28 17:18:40.563957');
INSERT INTO "search_click_logs" VALUES(266,'click',NULL,'seed-0f142b501ad7','bees','{"sort": "relevance", "page": 1}',NULL,265,48,1,'2026-10-28 17:18:50.563957');
INSERT INTO "search_click_logs" VALUES(267,'search',14,'seed-52ffe49c5edd','crispr','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-30 02:21:40.563957');
INSERT INTO "search_click_logs" VALUES(268,'click',14,'seed-52ffe49c5edd','crispr','{"sort": "relevance", "page": 1}',NULL,267,41,1,'2026-10-30 02:21:49.563957');
INSERT INTO "search_click_logs" VALUES(269,'click',14,'seed-52ffe49c5edd','crispr','{"sort": "relevance", "page": 1}',NULL,267,41,1,'2026-10-30 02:22:59.563957');
INSERT INTO "search_click_logs" VALUES(270,'search',13,'seed-1d75f309106e','exercise','{"sort": "relevance", "page": 1}',5,NULL,NULL,NULL,'2026-10-19 13:59:40.563957');
INSERT INTO "search_click_logs" VALUES(271,'click',13,'seed-1d75f309106e','exercise','{"sort": "relevance", "page": 1}',NULL,270,18,2,'2026-10-19 13:59:51.563957');
INSERT INTO "search_click_logs" VALUES(272,'search',1,'seed-8dd744e7a702','battery','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-21 23:14:40.563957');
INSERT INTO "search_click_logs" VALUES(273,'search',21,'seed-2025c903cc1d','gps','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-26 12:16:40.563957');
INSERT INTO "search_click_logs" VALUES(274,'click',21,'seed-2025c903cc1d','gps','{"sort": "relevance", "page": 1}',NULL,273,31,1,'2026-10-26 12:18:04.563957');
INSERT INTO "search_click_logs" VALUES(275,'search',12,'seed-fc3d8a5a4272','vaccine','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-10 02:21:40.563957');
INSERT INTO "search_click_logs" VALUES(276,'click',12,'seed-fc3d8a5a4272','vaccine','{"sort": "relevance", "page": 1}',NULL,275,56,2,'2026-10-10 02:22:54.563957');
INSERT INTO "search_click_logs" VALUES(277,'search',NULL,'seed-4a0c9ee827fa','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-30 15:21:40.563957');
INSERT INTO "search_click_logs" VALUES(278,'click',NULL,'seed-4a0c9ee827fa','spaced repetition','{"sort": "relevance", "page": 1}',NULL,277,19,1,'2026-10-30 15:22:44.563957');
INSERT INTO "search_click_logs" VALUES(279,'search',13,'seed-59f6ffce50b3','black hole','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-26 08:00:40.563957');
INSERT INTO "search_click_logs" VALUES(280,'search',2,'seed-bd3b29529420','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-07 21:36:40.563957');
INSERT INTO "search_click_logs" VALUES(281,'click',2,'seed-bd3b29529420','phishing','{"sort": "relevance", "page": 1}',NULL,280,53,1,'2026-10-07 21:36:58.563957');
INSERT INTO "search_click_logs" VALUES(282,'search',14,'seed-9c4635fa46fe','stress','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-11 21:40:40.563957');
INSERT INTO "search_click_logs" VALUES(283,'click',14,'seed-9c4635fa46fe','stress','{"sort": "relevance", "page": 1}',NULL,282,21,3,'2026-10-11 21:41:26.563957');
INSERT INTO "search_click_logs" VALUES(284,'click',14,'seed-9c4635fa46fe','stress','{"sort": "relevance", "page": 1}',NULL,282,46,2,'2026-10-11 21:41:40.563957');
INSERT INTO "search_click_logs" VALUES(285,'search',11,'seed-75b535eb728f','black hole','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-13 20:14:40.563957');
INSERT INTO "search_click_logs" VALUES(286,'search',21,'seed-0086ec191606','recycling','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-05 02:39:40.563957');
INSERT INTO "search_click_logs" VALUES(287,'click',21,'seed-0086ec191606','recycling','{"sort": "relevance", "page": 1}',NULL,286,39,1,'2026-10-05 02:40:05.563957');
INSERT INTO "search_click_logs" VALUES(288,'search',NULL,'seed-89c2648df4c0','index funds','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-05 14:31:40.563957');
INSERT INTO "search_click_logs" VALUES(289,'click',NULL,'seed-89c2648df4c0','index funds','{"sort": "relevance", "page": 1}',NULL,288,28,1,'2026-10-05 14:32:51.563957');
INSERT INTO "search_click_logs" VALUES(290,'click',NULL,'seed-89c2648df4c0','index funds','{"sort": "relevance", "page": 1}',NULL,288,28,1,'2026-10-05 14:33:08.563957');
INSERT INTO "search_click_logs" VALUES(291,'search',NULL,'seed-5ba399ef827f','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-29 18:22:40.563957');
INSERT INTO "search_click_logs" VALUES(292,'click',NULL,'seed-5ba399ef827f','spaced repetition','{"sort": "relevance", "page": 1}',NULL,291,40,2,'2026-10-29 18:22:44.563957');
INSERT INTO "search_click_logs" VALUES(293,'click',NULL,'seed-5ba399ef827f','spaced repetition','{"sort": "relevance", "page": 1}',NULL,291,19,1,'2026-10-29 18:23:30.563957');
INSERT INTO "search_click_logs" VALUES(294,'search',NULL,'seed-c22705106943','misinformation','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-20 23:39:40.563957');
INSERT INTO "search_click_logs" VALUES(295,'click',NULL,'seed-c22705106943','misinformation','{"sort": "relevance", "page": 1}',NULL,294,8,1,'2026-10-20 23:39:54.563957');
INSERT INTO "search_click_logs" VALUES(296,'click',NULL,'seed-c22705106943','misinformation','{"sort": "relevance", "page": 1}',NULL,294,8,1,'2026-10-20 23:41:03.563957');
INSERT INTO "search_click_logs" VALUES(297,'search',16,'seed-5cedf7a0be7a','recycling','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-11 23:13:40.563957');
INSERT INTO "search_click_logs" VALUES(298,'click',16,'seed-5cedf7a0be7a','recycling','{"sort": "relevance", "page": 1}',NULL,297,33,2,'2026-10-11 23:15:00.563957');
INSERT INTO "search_click_logs" VALUES(299,'search',13,'seed-deb21c66fdd9','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-27 09:25:40.563957');
INSERT INTO "search_click_logs" VALUES(300,'click',13,'seed-deb21c66fdd9','phishing','{"sort": "relevance", "page": 1}',NULL,299,53,1,'2026-10-27 09:26:07.563957');
INSERT INTO "search_click_logs" VALUES(301,'search',20,'seed-2cef90ad07c6','ocean','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-16 07:55:40.563957');
INSERT INTO "search_click_logs" VALUES(302,'click',20,'seed-2cef90ad07c6','ocean','{"sort": "relevance", "page": 1}',NULL,301,13,1,'2026-10-16 07:56:16.563957');
INSERT INTO "search_click_logs" VALUES(303,'search',NULL,'seed-463ac841b6a8','cash flow','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-06 13:21:40.563957');
INSERT INTO "search_click_logs" VALUES(304,'click',NULL,'seed-463ac841b6a8','cash flow','{"sort": "relevance", "page": 1}',NULL,303,42,2,'2026-10-06 13:23:09.563957');
INSERT INTO "search_click_logs" VALUES(305,'search',15,'seed-f01900801ed9','emergency fund','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-25 12:05:40.563957');
INSERT INTO "search_click_logs" VALUES(306,'click',15,'seed-f01900801ed9','emergency fund','{"sort": "relevance", "page": 1}',NULL,305,38,1,'2026-10-25 12:06:24.563957');
INSERT INTO "search_click_logs" VALUES(307,'search',4,'seed-84aeae1fd957','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-01 21:51:40.563957');
INSERT INTO "search_click_logs" VALUES(308,'click',4,'seed-84aeae1fd957','spaced repetition','{"sort": "relevance", "page": 1}',NULL,307,40,2,'2026-10-01 21:52:11.563957');
INSERT INTO "search_click_logs" VALUES(309,'search',15,'seed-015250f53bd8','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-04 13:02:40.563957');
INSERT INTO "search_click_logs" VALUES(310,'click',15,'seed-015250f53bd8','passkeys','{"sort": "relevance", "page": 1}',NULL,309,20,3,'2026-10-04 13:02:46.563957');
INSERT INTO "search_click_logs" VALUES(311,'search',14,'seed-130ef530c98d','vitamin d','{"sort": "relevance", "page": 1}',0,NULL,NULL,NULL,'2026-10-26 07:40:40.563957');
INSERT INTO "search_click_logs" VALUES(312,'search',10,'seed-a04110168d65','startup','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-27 19:58:40.563957');
INSERT INTO "search_click_logs" VALUES(313,'click',10,'seed-a04110168d65','startup','{"sort": "relevance", "page": 1}',NULL,312,50,1,'2026-10-27 19:58:46.563957');
INSERT INTO "search_click_logs" VALUES(314,'search',NULL,'seed-3f45401ad5cd','blood pressure','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-14 19:48:40.563957');
INSERT INTO "search_click_logs" VALUES(315,'click',NULL,'seed-3f45401ad5cd','blood pressure','{"sort": "relevance", "page": 1}',NULL,314,2,1,'2026-10-14 19:48:49.563957');
INSERT INTO "search_click_logs" VALUES(316,'search',3,'seed-9997c6978476','stress','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-18 23:08:40.563957');
INSERT INTO "search_click_logs" VALUES(317,'click',3,'seed-9997c6978476','stress','{"sort": "relevance", "page": 1}',NULL,316,46,2,'2026-10-18 23:09:57.563957');
INSERT INTO "search_click_logs" VALUES(318,'search',13,'seed-e3dc503314b1','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-02 06:04:40.563957');
INSERT INTO "search_click_logs" VALUES(319,'search',2,'seed-9c594d2d3557','password','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-28 16:07:40.563957');
INSERT INTO "search_click_logs" VALUES(320,'click',2,'seed-9c594d2d3557','password','{"sort": "relevance", "page": 1}',NULL,319,53,2,'2026-10-28 16:08:54.563957');
INSERT INTO "search_click_logs" VALUES(321,'search',4,'seed-c0809e07809d','password','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-06 17:30:40.563957');
INSERT INTO "search_click_logs" VALUES(322,'click',4,'seed-c0809e07809d','password','{"sort": "relevance", "page": 1}',NULL,321,53,2,'2026-10-06 17:32:02.563957');
INSERT INTO "search_click_logs" VALUES(323,'click',4,'seed-c0809e07809d','password','{"sort": "relevance", "page": 1}',NULL,321,27,1,'2026-10-06 17:31:32.563957');
INSERT INTO "search_click_logs" VALUES(324,'search',20,'seed-56f119ed59a5','battery','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-21 10:02:40.563957');
INSERT INTO "search_click_logs" VALUES(325,'click',20,'seed-56f119ed59a5','battery','{"sort": "relevance", "page": 1}',NULL,324,17,1,'2026-10-21 10:03:49.563957');
INSERT INTO "search_click_logs" VALUES(326,'search',1,'seed-b69a985d654b','recycling','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-28 03:42:40.563957');
INSERT INTO "search_click_logs" VALUES(327,'click',1,'seed-b69a985d654b','recycling','{"sort": "relevance", "page": 1}',NULL,326,39,1,'2026-10-28 03:43:56.563957');
INSERT INTO "search_click_logs" VALUES(328,'search',14,'seed-b9807b3cfc10','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-18 19:05:40.563957');
INSERT INTO "search_click_logs" VALUES(329,'click',14,'seed-b9807b3cfc10','sleep','{"sort": "relevance", "page": 1}',NULL,328,43,1,'2026-10-18 19:05:48.563957');
INSERT INTO "search_click_logs" VALUES(330,'search',17,'seed-a6d6f5b19be4','password','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-24 16:20:40.563957');
INSERT INTO "search_click_logs" VALUES(331,'search',5,'seed-4f057832b59c','recycling','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-06 02:14:40.563957');
INSERT INTO "search_click_logs" VALUES(332,'click',5,'seed-4f057832b59c','recycling','{"sort": "relevance", "page": 1}',NULL,331,12,3,'2026-10-06 02:15:49.563957');
INSERT INTO "search_click_logs" VALUES(333,'search',8,'seed-d1b681d1d226','exercise','{"sort": "relevance", "page": 1}',5,NULL,NULL,NULL,'2026-10-13 05:15:40.563957');
INSERT INTO "search_click_logs" VALUES(334,'search',7,'seed-e893a3fb6609','fibre','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-22 00:32:40.563957');
INSERT INTO "search_click_logs" VALUES(335,'click',7,'seed-e893a3fb6609','fibre','{"sort": "relevance", "page": 1}',NULL,334,24,1,'2026-10-22 00:33:43.563957');
INSERT INTO "search_click_logs" VALUES(336,'search',NULL,'seed-da1d54c5f266','salary','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-01 10:44:40.563957');
INSERT INTO "search_click_logs" VALUES(337,'click',NULL,'seed-da1d54c5f266','salary','{"sort": "relevance", "page": 1}',NULL,336,57,1,'2026-10-01 10:45:36.563957');
INSERT INTO "search_click_logs" VALUES(338,'click',NULL,'seed-da1d54c5f266','salary','{"sort": "relevance", "page": 1}',NULL,336,57,1,'2026-10-01 10:44:56.563957');
INSERT INTO "search_click_logs" VALUES(339,'search',16,'seed-eb82382afbde','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-09 05:46:40.563957');
INSERT INTO "search_click_logs" VALUES(340,'click',16,'seed-eb82382afbde','spaced repetition','{"sort": "relevance", "page": 1}',NULL,339,19,1,'2026-10-09 05:48:02.563957');
INSERT INTO "search_click_logs" VALUES(341,'search',NULL,'seed-603bbd75f95c','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-19 19:54:40.563957');
INSERT INTO "search_click_logs" VALUES(342,'click',NULL,'seed-603bbd75f95c','phishing','{"sort": "relevance", "page": 1}',NULL,341,20,3,'2026-10-19 19:55:29.563957');
INSERT INTO "search_click_logs" VALUES(343,'search',4,'seed-4a63247474b3','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-23 12:16:40.563957');
INSERT INTO "search_click_logs" VALUES(344,'click',4,'seed-4a63247474b3','passkeys','{"sort": "relevance", "page": 1}',NULL,343,20,3,'2026-10-23 12:17:29.563957');
INSERT INTO "search_click_logs" VALUES(345,'search',10,'seed-380c2c94df5a','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-31 00:27:40.563957');
INSERT INTO "search_click_logs" VALUES(346,'search',8,'seed-322c2db4e428','remote work','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-23 12:17:40.563957');
INSERT INTO "search_click_logs" VALUES(347,'click',8,'seed-322c2db4e428','remote work','{"sort": "relevance", "page": 1}',NULL,346,14,1,'2026-10-23 12:17:45.563957');
INSERT INTO "search_click_logs" VALUES(348,'click',8,'seed-322c2db4e428','remote work','{"sort": "relevance", "page": 1}',NULL,346,14,1,'2026-10-23 12:18:00.563957');
INSERT INTO "search_click_logs" VALUES(349,'search',11,'seed-35d2efa52c8a','inflation','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-10 03:25:40.563957');
INSERT INTO "search_click_logs" VALUES(350,'click',11,'seed-35d2efa52c8a','inflation','{"sort": "relevance", "page": 1}',NULL,349,60,2,'2026-10-10 03:27:07.563957');
INSERT INTO "search_click_logs" VALUES(351,'search',14,'seed-b600e0de0676','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-17 09:56:40.563957');
INSERT INTO "search_click_logs" VALUES(352,'click',14,'seed-b600e0de0676','sleep','{"sort": "relevance", "page": 1}',NULL,351,26,4,'2026-10-17 09:57:07.563957');
INSERT INTO "search_click_logs" VALUES(353,'search',11,'seed-6df6997c0dc9','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-22 18:26:40.563957');
INSERT INTO "search_click_logs" VALUES(354,'search',19,'seed-dabc3068ffdd','compound interest','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-30 10:11:40.563957');
INSERT INTO "search_click_logs" VALUES(355,'click',19,'seed-dabc3068ffdd','compound interest','{"sort": "relevance", "page": 1}',NULL,354,60,1,'2026-10-30 10:11:49.563957');
INSERT INTO "search_click_logs" VALUES(356,'search',17,'seed-9586f7e808a2','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-26 02:54:40.563957');
INSERT INTO "search_click_logs" VALUES(357,'search',NULL,'seed-9d69a9db47b9','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-29 15:09:40.563957');
INSERT INTO "search_click_logs" VALUES(358,'click',NULL,'seed-9d69a9db47b9','phishing','{"sort": "relevance", "page": 1}',NULL,357,27,2,'2026-10-29 15:11:05.563957');
INSERT INTO "search_click_logs" VALUES(359,'search',15,'seed-52632dd2d8c0','antibiotics','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-22 13:30:40.563957');
INSERT INTO "search_click_logs" VALUES(360,'click',15,'seed-52632dd2d8c0','antibiotics','{"sort": "relevance", "page": 1}',NULL,359,32,1,'2026-10-22 13:31:46.563957');
INSERT INTO "search_click_logs" VALUES(361,'search',NULL,'seed-a655957fe29f','battery','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-16 09:26:40.563957');
INSERT INTO "search_click_logs" VALUES(362,'click',NULL,'seed-a655957fe29f','battery','{"sort": "relevance", "page": 1}',NULL,361,17,1,'2026-10-16 09:27:13.563957');
INSERT INTO "search_click_logs" VALUES(363,'search',19,'seed-ef7c283edeec','inflation','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-24 18:20:40.563957');
INSERT INTO "search_click_logs" VALUES(364,'search',10,'seed-84d171cb19b3','black hole','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-30 04:20:40.563957');
INSERT INTO "search_click_logs" VALUES(365,'click',10,'seed-84d171cb19b3','black hole','{"sort": "relevance", "page": 1}',NULL,364,36,1,'2026-10-30 04:22:02.563957');
INSERT INTO "search_click_logs" VALUES(366,'search',14,'seed-cdf45e15433b','solar panels','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-20 16:27:40.563957');
INSERT INTO "search_click_logs" VALUES(367,'click',14,'seed-cdf45e15433b','solar panels','{"sort": "relevance", "page": 1}',NULL,366,9,1,'2026-10-20 16:28:39.563957');
INSERT INTO "search_click_logs" VALUES(368,'search',3,'seed-d7b44b658517','compound interest','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-14 18:57:40.563957');
INSERT INTO "search_click_logs" VALUES(369,'click',3,'seed-d7b44b658517','compound interest','{"sort": "relevance", "page": 1}',NULL,368,60,1,'2026-10-14 18:58:18.563957');
INSERT INTO "search_click_logs" VALUES(370,'search',12,'seed-8bc809cccf1a','cash flow','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-30 04:46:40.563957');
INSERT INTO "search_click_logs" VALUES(371,'click',12,'seed-8bc809cccf1a','cash flow','{"sort": "relevance", "page": 1}',NULL,370,16,1,'2026-10-30 04:47:21.563957');
INSERT INTO "search_click_logs" VALUES(372,'search',7,'seed-9aa1b4a4feee','language learning','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-09 21:50:40.563957');
INSERT INTO "search_click_logs" VALUES(373,'search',9,'seed-c523022f46bb','vitamin d','{"sort": "relevance", "page": 1}',0,NULL,NULL,NULL,'2026-10-10 12:40:40.563957');
INSERT INTO "search_click_logs" VALUES(374,'search',13,'seed-9477d26580c0','crispr','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-07 17:25:40.563957');
INSERT INTO "search_click_logs" VALUES(375,'search',13,'seed-3a173a42958b','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-14 02:07:40.563957');
INSERT INTO "search_click_logs" VALUES(376,'search',NULL,'seed-c1f38d783178','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-26 11:10:40.563957');
INSERT INTO "search_click_logs" VALUES(377,'click',NULL,'seed-c1f38d783178','phishing','{"sort": "relevance", "page": 1}',NULL,376,53,1,'2026-10-26 11:10:53.563957');
INSERT INTO "search_click_logs" VALUES(378,'click',NULL,'seed-c1f38d783178','phishing','{"sort": "relevance", "page": 1}',NULL,376,53,1,'2026-10-26 11:11:07.563957');
INSERT INTO "search_click_logs" VALUES(379,'search',7,'seed-7331704d628f','index funds','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-03 16:57:40.563957');
INSERT INTO "search_click_logs" VALUES(380,'search',10,'seed-bce0f17fa5c0','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-29 02:50:40.563957');
INSERT INTO "search_click_logs" VALUES(381,'click',10,'seed-bce0f17fa5c0','passkeys','{"sort": "relevance", "page": 1}',NULL,380,20,3,'2026-10-29 02:51:26.563957');
INSERT INTO "search_click_logs" VALUES(382,'click',10,'seed-bce0f17fa5c0','passkeys','{"sort": "relevance", "page": 1}',NULL,380,27,1,'2026-10-29 02:51:37.563957');
INSERT INTO "search_click_logs" VALUES(383,'search',18,'seed-53794cb50625','gps','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-21 07:38:40.563957');
INSERT INTO "search_click_logs" VALUES(384,'click',18,'seed-53794cb50625','gps','{"sort": "relevance", "page": 1}',NULL,383,31,1,'2026-10-21 07:39:00.563957');
INSERT INTO "search_click_logs" VALUES(385,'search',19,'seed-cc94a13d2600','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-02 19:56:40.563957');
INSERT INTO "search_click_logs" VALUES(386,'click',19,'seed-cc94a13d2600','sleep','{"sort": "relevance", "page": 1}',NULL,385,34,3,'2026-10-02 19:57:31.563957');
INSERT INTO "search_click_logs" VALUES(387,'search',13,'seed-798b3036f6b9','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-22 12:58:40.563957');
INSERT INTO "search_click_logs" VALUES(388,'click',13,'seed-798b3036f6b9','phishing','{"sort": "relevance", "page": 1}',NULL,387,53,1,'2026-10-22 12:59:21.563957');
INSERT INTO "search_click_logs" VALUES(389,'search',6,'seed-d3930835075f','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-29 12:20:40.563957');
INSERT INTO "search_click_logs" VALUES(390,'click',6,'seed-d3930835075f','heat pump','{"sort": "relevance", "page": 1}',NULL,389,15,1,'2026-10-29 12:20:51.563957');
INSERT INTO "search_click_logs" VALUES(391,'search',8,'seed-a8d94a85e443','startup','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-23 00:11:40.563957');
INSERT INTO "search_click_logs" VALUES(392,'click',8,'seed-a8d94a85e443','startup','{"sort": "relevance", "page": 1}',NULL,391,50,1,'2026-10-23 00:11:44.563957');
INSERT INTO "search_click_logs" VALUES(393,'search',13,'seed-fd56283379b8','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-06 17:11:40.563957');
INSERT INTO "search_click_logs" VALUES(394,'click',13,'seed-fd56283379b8','sleep','{"sort": "relevance", "page": 1}',NULL,393,43,1,'2026-10-06 17:11:51.563957');
INSERT INTO "search_click_logs" VALUES(395,'search',5,'seed-34a7ded5c017','inflation','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-05 00:10:40.563957');
INSERT INTO "search_click_logs" VALUES(396,'click',5,'seed-34a7ded5c017','inflation','{"sort": "relevance", "page": 1}',NULL,395,60,2,'2026-10-05 00:11:03.563957');
INSERT INTO "search_click_logs" VALUES(397,'click',5,'seed-34a7ded5c017','inflation','{"sort": "relevance", "page": 1}',NULL,395,25,1,'2026-10-05 00:11:22.563957');
INSERT INTO "search_click_logs" VALUES(398,'search',15,'seed-33a246834cc5','exercise','{"sort": "relevance", "page": 1}',5,NULL,NULL,NULL,'2026-10-18 07:50:40.563957');
INSERT INTO "search_click_logs" VALUES(399,'click',15,'seed-33a246834cc5','exercise','{"sort": "relevance", "page": 1}',NULL,398,21,1,'2026-10-18 07:51:34.563957');
INSERT INTO "search_click_logs" VALUES(400,'search',19,'seed-7dafe115d52b','blood pressure','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-26 19:59:40.563957');
INSERT INTO "search_click_logs" VALUES(401,'click',19,'seed-7dafe115d52b','blood pressure','{"sort": "relevance", "page": 1}',NULL,400,26,2,'2026-10-26 20:00:19.563957');
INSERT INTO "search_click_logs" VALUES(402,'search',NULL,'seed-b62ed7b73862','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-04 19:22:40.563957');
INSERT INTO "search_click_logs" VALUES(403,'search',14,'seed-2df83fc74cb8','inflation','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-08 01:14:40.563957');
INSERT INTO "search_click_logs" VALUES(404,'search',6,'seed-9190b2d2570a','language learning','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-20 08:43:40.563957');
INSERT INTO "search_click_logs" VALUES(405,'click',6,'seed-9190b2d2570a','language learning','{"sort": "relevance", "page": 1}',NULL,404,40,1,'2026-10-20 08:44:03.563957');
INSERT INTO "search_click_logs" VALUES(406,'search',NULL,'seed-1116ea92659b','black hole','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-14 21:15:40.563957');
INSERT INTO "search_click_logs" VALUES(407,'click',NULL,'seed-1116ea92659b','black hole','{"sort": "relevance", "page": 1}',NULL,406,36,1,'2026-10-14 21:16:46.563957');
INSERT INTO "search_click_logs" VALUES(408,'search',12,'seed-c1611397b542','index funds','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-10 03:04:40.563957');
INSERT INTO "search_click_logs" VALUES(409,'click',12,'seed-c1611397b542','index funds','{"sort": "relevance", "page": 1}',NULL,408,28,1,'2026-10-10 03:05:40.563957');
INSERT INTO "search_click_logs" VALUES(410,'search',15,'seed-12bc06d6fba7','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-28 05:41:40.563957');
INSERT INTO "search_click_logs" VALUES(411,'click',15,'seed-12bc06d6fba7','sleep','{"sort": "relevance", "page": 1}',NULL,410,43,1,'2026-10-28 05:42:26.563957');
INSERT INTO "search_click_logs" VALUES(412,'search',2,'seed-402702bfaf1c','language learning','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-06 17:40:40.563957');
INSERT INTO "search_click_logs" VALUES(413,'click',2,'seed-402702bfaf1c','language learning','{"sort": "relevance", "page": 1}',NULL,412,40,1,'2026-10-06 17:41:42.563957');
INSERT INTO "search_click_logs" VALUES(414,'click',2,'seed-402702bfaf1c','language learning','{"sort": "relevance", "page": 1}',NULL,412,40,1,'2026-10-06 17:40:51.563957');
INSERT INTO "search_click_logs" VALUES(415,'search',5,'seed-d20778858b6d','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-13 16:16:40.563957');
INSERT INTO "search_click_logs" VALUES(416,'click',5,'seed-d20778858b6d','heat pump','{"sort": "relevance", "page": 1}',NULL,415,15,1,'2026-10-13 16:18:00.563957');
INSERT INTO "search_click_logs" VALUES(417,'search',NULL,'seed-2b1f640eb68e','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-24 12:58:40.563957');
INSERT INTO "search_click_logs" VALUES(418,'click',NULL,'seed-2b1f640eb68e','heat pump','{"sort": "relevance", "page": 1}',NULL,417,15,1,'2026-10-24 12:59:02.563957');
INSERT INTO "search_click_logs" VALUES(419,'search',NULL,'seed-37568844bc0c','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-28 06:02:40.563957');
INSERT INTO "search_click_logs" VALUES(420,'click',NULL,'seed-37568844bc0c','spaced repetition','{"sort": "relevance", "page": 1}',NULL,419,19,1,'2026-10-28 06:03:49.563957');
INSERT INTO "search_click_logs" VALUES(421,'search',13,'seed-4eeeb0ba8fe3','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-12 03:42:40.563957');
INSERT INTO "search_click_logs" VALUES(422,'click',13,'seed-4eeeb0ba8fe3','climate','{"sort": "relevance", "page": 1}',NULL,421,13,1,'2026-10-12 03:43:31.563957');
INSERT INTO "search_click_logs" VALUES(423,'search',8,'seed-17653332432b','bees','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-03 18:25:40.563957');
INSERT INTO "search_click_logs" VALUES(424,'click',8,'seed-17653332432b','bees','{"sort": "relevance", "page": 1}',NULL,423,48,1,'2026-10-03 18:26:07.563957');
INSERT INTO "search_click_logs" VALUES(425,'search',NULL,'seed-d498d5dbcbee','gps','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-31 03:55:40.563957');
INSERT INTO "search_click_logs" VALUES(426,'click',NULL,'seed-d498d5dbcbee','gps','{"sort": "relevance", "page": 1}',NULL,425,31,1,'2026-10-31 03:56:48.563957');
INSERT INTO "search_click_logs" VALUES(427,'search',21,'seed-9fea30862fe3','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-23 12:01:40.563957');
INSERT INTO "search_click_logs" VALUES(428,'click',21,'seed-9fea30862fe3','heat pump','{"sort": "relevance", "page": 1}',NULL,427,15,1,'2026-10-23 12:01:58.563957');
INSERT INTO "search_click_logs" VALUES(429,'search',6,'seed-66f203d6af3f','compound interest','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-29 20:10:40.563957');
INSERT INTO "search_click_logs" VALUES(430,'click',6,'seed-66f203d6af3f','compound interest','{"sort": "relevance", "page": 1}',NULL,429,60,1,'2026-10-29 20:11:11.563957');
INSERT INTO "search_click_logs" VALUES(431,'search',20,'seed-0b3f5e75788f','password','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-08 09:01:40.563957');
INSERT INTO "search_click_logs" VALUES(432,'click',20,'seed-0b3f5e75788f','password','{"sort": "relevance", "page": 1}',NULL,431,27,1,'2026-10-08 09:02:59.563957');
INSERT INTO "search_click_logs" VALUES(433,'search',NULL,'seed-ec16fd93754a','vaccine','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-01 12:54:40.563957');
INSERT INTO "search_click_logs" VALUES(434,'search',11,'seed-a180fb3e127f','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-02 10:44:40.563957');
INSERT INTO "search_click_logs" VALUES(435,'click',11,'seed-a180fb3e127f','sleep','{"sort": "relevance", "page": 1}',NULL,434,26,4,'2026-10-02 10:45:00.563957');
INSERT INTO "search_click_logs" VALUES(436,'search',11,'seed-d9fffa5f9e72','recycling','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-14 07:44:40.563957');
INSERT INTO "search_click_logs" VALUES(437,'click',11,'seed-d9fffa5f9e72','recycling','{"sort": "relevance", "page": 1}',NULL,436,39,1,'2026-10-14 07:45:57.563957');
INSERT INTO "search_click_logs" VALUES(438,'search',17,'seed-b462966456be','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-18 23:16:40.563957');
INSERT INTO "search_click_logs" VALUES(439,'search',10,'seed-bce73c847821','compound interest','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-16 02:58:40.563957');
INSERT INTO "search_click_logs" VALUES(440,'click',10,'seed-bce73c847821','compound interest','{"sort": "relevance", "page": 1}',NULL,439,60,1,'2026-10-16 02:59:00.563957');
INSERT INTO "search_click_logs" VALUES(441,'search',13,'seed-a45c345298c4','inflation','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-25 02:02:40.563957');
INSERT INTO "search_click_logs" VALUES(442,'click',13,'seed-a45c345298c4','inflation','{"sort": "relevance", "page": 1}',NULL,441,25,1,'2026-10-25 02:03:39.563957');
INSERT INTO "search_click_logs" VALUES(443,'click',13,'seed-a45c345298c4','inflation','{"sort": "relevance", "page": 1}',NULL,441,60,2,'2026-10-25 02:03:25.563957');
INSERT INTO "search_click_logs" VALUES(444,'search',17,'seed-fa41cab21438','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-25 05:51:40.563957');
INSERT INTO "search_click_logs" VALUES(445,'click',17,'seed-fa41cab21438','sleep','{"sort": "relevance", "page": 1}',NULL,444,34,3,'2026-10-25 05:52:12.563957');
INSERT INTO "search_click_logs" VALUES(446,'click',17,'seed-fa41cab21438','sleep','{"sort": "relevance", "page": 1}',NULL,444,34,3,'2026-10-25 05:52:25.563957');
INSERT INTO "search_click_logs" VALUES(447,'search',NULL,'seed-3f93fd063a58','solar panels','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-28 05:22:40.563957');
INSERT INTO "search_click_logs" VALUES(448,'search',17,'seed-2efc5256cd59','salary','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-26 18:11:40.563957');
INSERT INTO "search_click_logs" VALUES(449,'click',17,'seed-2efc5256cd59','salary','{"sort": "relevance", "page": 1}',NULL,448,57,1,'2026-10-26 18:11:51.563957');
INSERT INTO "search_click_logs" VALUES(450,'search',7,'seed-177d2024c407','quantum computing','{"sort": "relevance", "page": 1}',0,NULL,NULL,NULL,'2026-10-31 02:23:40.563957');
INSERT INTO "search_click_logs" VALUES(451,'search',8,'seed-140281e6935f','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-18 00:14:40.563957');
INSERT INTO "search_click_logs" VALUES(452,'click',8,'seed-140281e6935f','sleep','{"sort": "relevance", "page": 1}',NULL,451,43,1,'2026-10-18 00:15:08.563957');
INSERT INTO "search_click_logs" VALUES(453,'search',10,'seed-9390490ce315','compound interest','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-27 22:43:40.563957');
INSERT INTO "search_click_logs" VALUES(454,'click',10,'seed-9390490ce315','compound interest','{"sort": "relevance", "page": 1}',NULL,453,60,1,'2026-10-27 22:44:44.563957');
INSERT INTO "search_click_logs" VALUES(455,'search',13,'seed-78802af2b718','password','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-02 17:37:40.563957');
INSERT INTO "search_click_logs" VALUES(456,'click',13,'seed-78802af2b718','password','{"sort": "relevance", "page": 1}',NULL,455,53,2,'2026-10-02 17:38:02.563957');
INSERT INTO "search_click_logs" VALUES(457,'search',NULL,'seed-6d6961a4b230','stress','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-09 06:32:40.563957');
INSERT INTO "search_click_logs" VALUES(458,'search',18,'seed-8d87271dd0f1','antibiotics','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-04 10:54:40.563957');
INSERT INTO "search_click_logs" VALUES(459,'search',10,'seed-8fe86009a05a','black hole','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-19 15:44:40.563957');
INSERT INTO "search_click_logs" VALUES(460,'click',10,'seed-8fe86009a05a','black hole','{"sort": "relevance", "page": 1}',NULL,459,36,1,'2026-10-19 15:45:43.563957');
INSERT INTO "search_click_logs" VALUES(461,'search',1,'seed-802ddc956e31','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-05 07:04:40.563957');
INSERT INTO "search_click_logs" VALUES(462,'search',13,'seed-be00f8723487','inflation','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-21 17:01:40.563957');
INSERT INTO "search_click_logs" VALUES(463,'click',13,'seed-be00f8723487','inflation','{"sort": "relevance", "page": 1}',NULL,462,60,2,'2026-10-21 17:02:58.563957');
INSERT INTO "search_click_logs" VALUES(464,'search',13,'seed-90cbeea00af9','password','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-06 02:58:40.563957');
INSERT INTO "search_click_logs" VALUES(465,'click',13,'seed-90cbeea00af9','password','{"sort": "relevance", "page": 1}',NULL,464,20,3,'2026-10-06 02:59:27.563957');
INSERT INTO "search_click_logs" VALUES(466,'search',12,'seed-0ec5b24ae6e3','vaccine','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-19 07:42:40.563957');
INSERT INTO "search_click_logs" VALUES(467,'click',12,'seed-0ec5b24ae6e3','vaccine','{"sort": "relevance", "page": 1}',NULL,466,56,2,'2026-10-19 07:43:14.563957');
INSERT INTO "search_click_logs" VALUES(468,'click',12,'seed-0ec5b24ae6e3','vaccine','{"sort": "relevance", "page": 1}',NULL,466,4,1,'2026-10-19 07:43:29.563957');
INSERT INTO "search_click_logs" VALUES(469,'search',NULL,'seed-25dba5349425','climate','{"sort": "relevance", "page": 1}',9,NULL,NULL,NULL,'2026-10-12 07:24:40.563957');
INSERT INTO "search_click_logs" VALUES(470,'click',NULL,'seed-25dba5349425','climate','{"sort": "relevance", "page": 1}',NULL,469,45,4,'2026-10-12 07:25:15.563957');
INSERT INTO "search_click_logs" VALUES(471,'search',NULL,'seed-032829534ea7','compound interest','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-16 08:35:40.563957');
INSERT INTO "search_click_logs" VALUES(472,'click',NULL,'seed-032829534ea7','compound interest','{"sort": "relevance", "page": 1}',NULL,471,60,1,'2026-10-16 08:36:32.563957');
INSERT INTO "search_click_logs" VALUES(473,'search',17,'seed-3056e8f26d63','inflation','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-17 04:28:40.563957');
INSERT INTO "search_click_logs" VALUES(474,'search',10,'seed-f7ba802a63cc','sleep','{"sort": "relevance", "page": 1}',4,NULL,NULL,NULL,'2026-10-21 07:36:40.563957');
INSERT INTO "search_click_logs" VALUES(475,'click',10,'seed-f7ba802a63cc','sleep','{"sort": "relevance", "page": 1}',NULL,474,6,2,'2026-10-21 07:37:35.563957');
INSERT INTO "search_click_logs" VALUES(476,'click',10,'seed-f7ba802a63cc','sleep','{"sort": "relevance", "page": 1}',NULL,474,34,3,'2026-10-21 07:36:54.563957');
INSERT INTO "search_click_logs" VALUES(477,'search',NULL,'seed-44de2488dee3','heat pump','{"sort": "relevance", "page": 1}',1,NULL,NULL,NULL,'2026-10-16 19:27:40.563957');
INSERT INTO "search_click_logs" VALUES(478,'search',1,'seed-2b1cfcadb3fd','cash flow','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-21 20:42:40.563957');
INSERT INTO "search_click_logs" VALUES(479,'search',14,'seed-6ab68663e8bb','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-30 07:26:40.563957');
INSERT INTO "search_click_logs" VALUES(480,'click',14,'seed-6ab68663e8bb','passkeys','{"sort": "relevance", "page": 1}',NULL,479,27,1,'2026-10-30 07:27:30.563957');
INSERT INTO "search_click_logs" VALUES(481,'search',6,'seed-f2cf80ab4b7f','phishing','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-28 14:36:40.563957');
INSERT INTO "search_click_logs" VALUES(482,'click',6,'seed-f2cf80ab4b7f','phishing','{"sort": "relevance", "page": 1}',NULL,481,53,1,'2026-10-28 14:37:08.563957');
INSERT INTO "search_click_logs" VALUES(483,'search',9,'seed-e6fbfba26c21','password','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-28 00:40:40.563957');
INSERT INTO "search_click_logs" VALUES(484,'search',21,'seed-146e2a873e02','spaced repetition','{"sort": "relevance", "page": 1}',2,NULL,NULL,NULL,'2026-10-05 03:29:40.563957');
INSERT INTO "search_click_logs" VALUES(485,'click',21,'seed-146e2a873e02','spaced repetition','{"sort": "relevance", "page": 1}',NULL,484,19,1,'2026-10-05 03:30:26.563957');
INSERT INTO "search_click_logs" VALUES(486,'search',NULL,'seed-19cec2b2547d','passkeys','{"sort": "relevance", "page": 1}',3,NULL,NULL,NULL,'2026-10-26 14:39:40.563957');
INSERT INTO "search_click_logs" VALUES(487,'click',NULL,'seed-19cec2b2547d','passkeys','{"sort": "relevance", "page": 1}',NULL,486,20,3,'2026-10-26 14:41:08.563957');
INSERT INTO "search_click_logs" VALUES(488,'search',7,'seed-cab285b7b774','exercise','{"sort": "relevance", "page": 1}',5,NULL,NULL,NULL,'2026-10-02 03:54:40.563957');
INSERT INTO "search_click_logs" VALUES(489,'click',7,'seed-cab285b7b774','exercise','{"sort": "relevance", "page": 1}',NULL,488,2,5,'2026-10-02 03:55:17.563957');
INSERT INTO "search_click_logs" VALUES(490,'search',22,'9b3716ffa3964229aa7865b337078aaa','a','{"sort": "relevance", "page": 1}',57,NULL,NULL,NULL,'2026-10-31 07:24:17.953980');
CREATE TABLE seo_metadata (
	document_id INTEGER NOT NULL, 
	meta_title VARCHAR(255) NOT NULL, 
	meta_description VARCHAR(500) NOT NULL, 
	keywords VARCHAR(500) NOT NULL, 
	image_alt VARCHAR(255) NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (document_id), 
	FOREIGN KEY(document_id) REFERENCES documents (id) ON DELETE CASCADE
);
INSERT INTO "seo_metadata" VALUES(3,'Note-taking methods compared','','','','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(4,'How vaccines train the immune system | Margin','Vaccines show the immune system a harmless preview of a germ so it can respond faster to the real thing. Different vaccine types deliver that preview in...','biology, medicine, public health','Abstract illustration for the article ''How vaccines train the immune system''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(5,'Why peer review matters, and where it falls short | Margin','Before most research is published, other experts scrutinise it. Peer review catches many problems, but it was never designed to guarantee that a result is true.','research, universities','Abstract illustration for the article ''Why peer review matters, and where it falls short''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(6,'How much sleep do adults really need?','','','','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(7,'Teaching children about money | Margin','Children form money habits early. Age-appropriate lessons about saving, spending and earning prepare them for financial independence.','money, schools','Abstract illustration for the article ''Teaching children about money''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(8,'Critical thinking in an age of misinformation | Margin','False and misleading information spreads quickly online. A few habits, such as lateral reading and checking original sources, help anyone evaluate claims.','learning, internet, schools','Abstract illustration for the article ''Critical thinking in an age of misinformation''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(9,'Solar panels: from sunlight to socket | Margin','Photovoltaic cells turn sunlight directly into electricity. How the technology works, why costs have fallen so far, and what happens when the sun goes down.','energy, climate','Abstract illustration for the article ''Solar panels: from sunlight to socket''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(10,'What makes a good scientific experiment | Margin','Control groups, randomisation and blinding are not bureaucratic rituals. Each one removes a specific way that we fool ourselves.','research, learning','Abstract illustration for the article ''What makes a good scientific experiment''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(11,'What a chip shortage teaches us about supply chains | Margin','When semiconductors ran short, cars and consoles were delayed worldwide. The episode revealed how concentrated and slow-moving chip production is.','hardware, economics','Abstract illustration for the article ''What a chip shortage teaches us about supply chains''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(12,'Food waste: where it happens and how to cut it | Margin','A large share of the food produced worldwide is never eaten. Losses happen on farms, in shops and in homes, and each stage has practical fixes.','recycling, nutrition, climate','Abstract illustration for the article ''Food waste: where it happens and how to cut it''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(13,'The ocean''s role in regulating the climate','','','','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(14,'Remote work after the great experiment | Margin','Many office workers went remote almost overnight, and hybrid arrangements are now common. What has research and experience taught employers and employees?','careers, economics','Abstract illustration for the article ''Remote work after the great experiment''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(15,'How heat pumps heat and cool a home | Margin','A heat pump moves heat instead of making it, which is why it can deliver several units of heat for every unit of electricity it uses.','energy, climate','Abstract illustration for the article ''How heat pumps heat and cool a home''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(16,'Small businesses and the cash flow trap | Margin','Profitable small businesses still fail when cash runs out. Understanding the timing of money in and money out is essential for survival.','startups, money','Abstract illustration for the article ''Small businesses and the cash flow trap''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(17,'Why your phone battery wears out, and how to slow it down | Margin','Lithium-ion batteries lose capacity with every cycle, and heat speeds the process up. A few habits can noticeably extend their useful life.','hardware, energy','Abstract illustration for the article ''Why your phone battery wears out, and how to slow it down''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(18,'Building an exercise habit that lasts | Margin','Motivation fades; routines remain. Behaviour research suggests starting smaller than you think and making activity easy to repeat.','exercise, mental health','Abstract illustration for the article ''Building an exercise habit that lasts''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(19,'Spaced repetition: study less, remember more | Margin','Reviewing material at increasing intervals fights the natural forgetting curve. It is one of the best-supported techniques in learning science.','learning, research','Abstract illustration for the article ''Spaced repetition: study less, remember more''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(20,'Two-factor authentication: which method should you choose? | Margin','Text-message codes, authenticator apps and security keys all add a second step to logging in, but they are not equally strong.','cybersecurity, privacy','Abstract illustration for the article ''Two-factor authentication: which method should you choose?''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(22,'Why the sky is blue and sunsets are red | Margin','Sunlight contains every colour, but air molecules scatter short blue wavelengths far more than red ones. The same effect paints the evening sky.','physics','Abstract illustration for the article ''Why the sky is blue and sunsets are red''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(23,'Choosing a university major | Margin','Choosing a field of study can feel like a lifelong decision, but most careers are more flexible than that. Interests, skills and exploration all deserve weight.','universities, careers','Abstract illustration for the article ''Choosing a university major''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(24,'Fibre: the nutrient most diets lack | Margin','Fibre supports digestion, steadies blood sugar and feeds helpful gut bacteria. Most people eat far less than recommended, but small swaps add up.','nutrition','Abstract illustration for the article ''Fibre: the nutrient most diets lack''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(25,'Inflation explained with a grocery basket | Margin','Inflation measures how the price of a typical basket of goods changes over time. What causes it, how it is measured, and why a little is considered normal.','economics, money','Abstract illustration for the article ''Inflation explained with a grocery basket''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(26,'What stress does to the body | Margin','The stress response evolved for short emergencies. When it stays switched on for weeks, it affects sleep, digestion, mood and more.','mental health, sleep','Abstract illustration for the article ''What stress does to the body''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(27,'Passkeys explained: how they replace passwords | Margin','Passkeys let you sign in with your fingerprint, face or device PIN instead of a password. Here is what happens behind the scenes and why they resist phishing.','cybersecurity, privacy, internet','Abstract illustration for the article ''Passkeys explained: how they replace passwords''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(28,'Index funds: why many investors keep it simple | Margin','Index funds hold all the companies in a market index instead of trying to pick winners. Low costs and broad diversification explain their popularity.','money, economics','Abstract illustration for the article ''Index funds: why many investors keep it simple''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(29,'Hand washing: the simplest public health tool | Margin','Washing hands with soap for about 20 seconds removes germs that spread colds, stomach bugs and more. Technique matters more than people think.','public health, medicine','Abstract illustration for the article ''Hand washing: the simplest public health tool''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(30,'How to read a scientific paper','','','','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(31,'How GPS knows where you are, relativity included | Margin','Your phone finds its position by timing signals from satellites. The clocks are so precise that Einstein''s theories have to be built into the system.','physics, space, hardware','Abstract illustration for the article ''How GPS knows where you are, relativity included''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(32,'How antibiotics work, and why resistance is rising | Margin','Antibiotics kill bacteria or stop them multiplying, but every use gives resistant strains an advantage. Why finishing the right course, and skipping...','medicine, public health, biology','Abstract illustration for the article ''How antibiotics work, and why resistance is rising''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(33,'Electric cars: how lifetime emissions compare | Margin','Building an electric car''s battery creates extra emissions at the start, but lower emissions on the road usually make up for it over the vehicle''s life.','energy, climate','Abstract illustration for the article ''Electric cars: how lifetime emissions compare''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(35,'How central banks use interest rates | Margin','Central banks raise or lower a key interest rate to steer inflation and employment. The effects ripple through loans, savings, currencies and asset prices.','economics, money','Abstract illustration for the article ''How central banks use interest rates''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(36,'Black holes without the jargon | Margin','A black hole is a region where gravity is so strong that not even light can escape. Here is how they form and how astronomers study something invisible.','space, physics','Abstract illustration for the article ''Black holes without the jargon''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(37,'How urban trees cool our cities | Margin','Cities can be several degrees hotter than the surrounding countryside. Trees provide shade and evaporative cooling, making streets more comfortable and...','climate, cities','Abstract illustration for the article ''How urban trees cool our cities''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(38,'How to build an emergency fund | Margin','An emergency fund turns a crisis into an inconvenience. How much to aim for, where to keep it and how to build it without feeling deprived.','money','Abstract illustration for the article ''How to build an emergency fund''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(39,'What really happens to your recycling | Margin','Your recycling bin is the first step in a long sorting process. Contamination and mixed materials are the main reasons items end up wasted.','recycling','Abstract illustration for the article ''What really happens to your recycling''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(40,'Learning a language as an adult | Margin','Children are not the only ones who can learn languages. Adults bring advantages of their own, and the right habits make steady progress possible.','learning','Abstract illustration for the article ''Learning a language as an adult''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(41,'CRISPR gene editing: what it can and cannot do','','','','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(43,'Why sleep matters for students | Margin','Sleep is when the brain consolidates what you learned during the day. Pulling all-nighters before exams often undermines the very performance students want.','sleep, schools, learning','Abstract illustration for the article ''Why sleep matters for students''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(44,'Large language models, in plain words | Margin','Chat assistants are built on models trained to predict the next piece of text. Understanding that one idea explains both their strengths and their mistakes.','artificial intelligence, software','Abstract illustration for the article ''Large language models, in plain words''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(45,'Hydration myths and facts | Margin','Do you really need eight glasses of water a day? Fluid needs vary, food counts, and thirst is a useful guide for most healthy people.','nutrition, exercise','Abstract illustration for the article ''Hydration myths and facts''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(46,'Coral reefs under pressure | Margin','Coral reefs cover a tiny part of the ocean floor yet host a remarkable share of marine species. Warming water causes bleaching, which can kill corals if it...','oceans, wildlife, climate','Abstract illustration for the article ''Coral reefs under pressure''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(47,'Open-source software runs the world. Who maintains it? | Margin','From web servers to the libraries inside your phone apps, open-source code is everywhere. Much of it depends on a small number of volunteers.','software, careers','Abstract illustration for the article ''Open-source software runs the world. Who maintains it?''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(48,'Why bees and other pollinators matter','','','','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(49,'The testing effect: why quizzes beat rereading | Margin','Retrieving information from memory strengthens it more than reviewing notes. Low-stakes self-testing is a simple, powerful study strategy.','learning, schools','Abstract illustration for the article ''The testing effect: why quizzes beat rereading''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(50,'What startups mean by product-market fit | Margin','Product-market fit is the point where a product satisfies a strong market demand. Founders talk about it constantly because almost nothing else matters...','startups, careers','Abstract illustration for the article ''What startups mean by product-market fit''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(52,'Online courses: how to actually finish one | Margin','Many people sign up for online courses but few complete them. Treating the course like a real class, with a schedule and community, changes the odds.','learning, careers','Abstract illustration for the article ''Online courses: how to actually finish one''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(53,'Spotting phishing messages before they spot you | Margin','Phishing relies on urgency and imitation. Learning a handful of warning signs, and one golden rule, prevents most account takeovers.','cybersecurity, internet','Abstract illustration for the article ''Spotting phishing messages before they spot you''','2026-10-31 07:12:40.758146');
INSERT INTO "seo_metadata" VALUES(54,'How scientists date ancient objects with carbon-14 | Margin','Living things absorb a trace of radioactive carbon that decays at a steady rate after death. Measuring what is left reveals an age of up to around 50,000 years.','chemistry, research','Abstract illustration for the article ''How scientists date ancient objects with carbon-14''','2026-10-31 07:12:40.759146');
INSERT INTO "seo_metadata" VALUES(56,'Tardigrades: the toughest animals on Earth | Margin','These half-millimetre animals survive freezing, boiling, radiation and even the vacuum of space by entering a state of suspended animation.','biology, wildlife','Abstract illustration for the article ''Tardigrades: the toughest animals on Earth''','2026-10-31 07:12:40.759146');
INSERT INTO "seo_metadata" VALUES(57,'Negotiating a salary offer without awkwardness | Margin','Many people accept the first offer they receive. Preparation, a clear number and a collaborative tone make negotiation far less uncomfortable.','careers, money','Abstract illustration for the article ''Negotiating a salary offer without awkwardness''','2026-10-31 07:12:40.759146');
INSERT INTO "seo_metadata" VALUES(59,'Cloud storage or local backups? Building a sensible backup plan | Margin','Sync is not the same as backup. The 3-2-1 rule offers a simple way to protect photos and documents against theft, failure and mistakes.','software, hardware, privacy','Abstract illustration for the article ''Cloud storage or local backups? Building a sensible backup plan''','2026-10-31 07:12:40.759146');
INSERT INTO "seo_metadata" VALUES(60,'Compound interest: the quiet engine of savings | Margin','Compound interest means earning returns on your previous returns. Time matters more than most people expect, for savings and for debt.','money, economics','Abstract illustration for the article ''Compound interest: the quiet engine of savings''','2026-10-31 07:12:40.759146');
CREATE TABLE settings (
	"key" VARCHAR(60) NOT NULL, 
	value TEXT NOT NULL, 
	PRIMARY KEY ("key")
);
INSERT INTO "settings" VALUES('site_name','Margin');
INSERT INTO "settings" VALUES('site_tagline','Clear explainers on technology, science, health and the world around us.');
INSERT INTO "settings" VALUES('page_size','9');
INSERT INTO "settings" VALUES('allow_registration','true');
INSERT INTO "settings" VALUES('comments_require_approval','false');
INSERT INTO "settings" VALUES('max_links_per_comment','2');
INSERT INTO "settings" VALUES('comment_rate_limit_per_minute','5');
INSERT INTO "settings" VALUES('spam_keywords','free money, casino, crypto giveaway, click here, buy followers, viagra, loan approval');
CREATE TABLE tags (
	id INTEGER NOT NULL, 
	name VARCHAR(60) NOT NULL, 
	slug VARCHAR(70) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
INSERT INTO "tags" VALUES(1,'Cybersecurity','cybersecurity');
INSERT INTO "tags" VALUES(2,'Privacy','privacy');
INSERT INTO "tags" VALUES(3,'Internet','internet');
INSERT INTO "tags" VALUES(4,'Software','software');
INSERT INTO "tags" VALUES(5,'Artificial Intelligence','artificial-intelligence');
INSERT INTO "tags" VALUES(6,'Hardware','hardware');
INSERT INTO "tags" VALUES(7,'Energy','energy');
INSERT INTO "tags" VALUES(8,'Careers','careers');
INSERT INTO "tags" VALUES(9,'Economics','economics');
INSERT INTO "tags" VALUES(10,'Physics','physics');
INSERT INTO "tags" VALUES(11,'Biology','biology');
INSERT INTO "tags" VALUES(12,'Medicine','medicine');
INSERT INTO "tags" VALUES(13,'Public Health','public-health');
INSERT INTO "tags" VALUES(14,'Space','space');
INSERT INTO "tags" VALUES(15,'Research','research');
INSERT INTO "tags" VALUES(16,'Chemistry','chemistry');
INSERT INTO "tags" VALUES(17,'Universities','universities');
INSERT INTO "tags" VALUES(18,'Wildlife','wildlife');
INSERT INTO "tags" VALUES(19,'Learning','learning');
INSERT INTO "tags" VALUES(20,'Sleep','sleep');
INSERT INTO "tags" VALUES(21,'Mental Health','mental-health');
INSERT INTO "tags" VALUES(22,'Exercise','exercise');
INSERT INTO "tags" VALUES(23,'Nutrition','nutrition');
INSERT INTO "tags" VALUES(24,'Climate','climate');
INSERT INTO "tags" VALUES(25,'Oceans','oceans');
INSERT INTO "tags" VALUES(26,'Recycling','recycling');
INSERT INTO "tags" VALUES(27,'Cities','cities');
INSERT INTO "tags" VALUES(28,'Water','water');
INSERT INTO "tags" VALUES(29,'Money','money');
INSERT INTO "tags" VALUES(30,'Startups','startups');
INSERT INTO "tags" VALUES(31,'Schools','schools');
CREATE TABLE users (
	id INTEGER NOT NULL, 
	username VARCHAR(40) NOT NULL, 
	email VARCHAR(255) NOT NULL, 
	password_hash VARCHAR(255) NOT NULL, 
	full_name VARCHAR(120) NOT NULL, 
	bio TEXT NOT NULL, 
	avatar_url VARCHAR(500), 
	role_id INTEGER NOT NULL, 
	is_active BOOLEAN NOT NULL, 
	created_at DATETIME NOT NULL, 
	last_login_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(role_id) REFERENCES roles (id)
);
INSERT INTO "users" VALUES(1,'admin','admin@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Morgan Lee','Runs the platform: accounts, permissions and settings.',NULL,1,1,'2026-03-05 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(2,'editor','editor@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Priya Shah','Managing editor. Plans the publishing calendar.',NULL,2,1,'2026-03-10 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(3,'moderator','moderator@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Ethan Brooks','Keeps the comment sections friendly and spam-free.',NULL,3,1,'2026-03-15 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(4,'seo','seo@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Mai Hoang','Looks after search visibility and audience analytics.',NULL,4,1,'2026-03-20 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(5,'reader','reader@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Jordan Ellis','Curious reader. Mostly here for science and money articles.',NULL,5,1,'2026-03-25 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(6,'lan_pham','lan_pham@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Lan Pham','Technology and security writer.',NULL,2,1,'2026-03-30 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(7,'daniel_okafor','daniel_okafor@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Daniel Okafor','Writes about the economy, the internet and the environment.',NULL,2,1,'2026-04-04 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(8,'clara_jensen','clara_jensen@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Clara Jensen','Science and health writer with a background in biology.',NULL,2,1,'2026-04-09 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(9,'tomas_silva','tomas_silva@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Tomas Silva','Covers energy, personal finance and space.',NULL,2,1,'2026-04-14 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(10,'anna_k','anna_k@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Anna Kowalski','Secondary school science teacher.',NULL,5,1,'2026-04-19 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(11,'ben_carter','ben_carter@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Ben Carter','Software developer and amateur astronomer.',NULL,5,1,'2026-04-24 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(12,'chi_nguyen','chi_nguyen@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Chi Nguyen','Nursing student.',NULL,5,1,'2026-04-29 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(13,'david_m','david_m@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','David Mensah','Small business owner, coffee enthusiast.',NULL,5,1,'2026-05-04 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(14,'elif_y','elif_y@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Elif Yilmaz','Urban planner interested in green cities.',NULL,5,1,'2026-05-09 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(15,'farah_n','farah_n@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Farah Nasser','Data analyst. Loves a good chart.',NULL,5,1,'2026-05-14 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(16,'gabe_r','gabe_r@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Gabriel Rossi','Retired engineer.',NULL,5,1,'2026-05-19 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(17,'huong_le','huong_le@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Huong Le','University student studying economics.',NULL,5,1,'2026-05-24 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(18,'ivan_p','ivan_p@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Ivan Petrov','Cyclist and climate volunteer.',NULL,5,1,'2026-05-29 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(19,'julia_s','julia_s@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Julia Santos','Language learner (currently Japanese).',NULL,5,1,'2026-06-03 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(20,'kenji_t','kenji_t@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Kenji Tanaka','Product manager at a startup.',NULL,5,1,'2026-06-08 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(21,'lucia_g','lucia_g@margin.demo','$2b$10$gQ3X6e7kM3kH190c1z0CBuEH7LANI54XSYZp64M0I0HrTNAse82sO','Lucia Garcia','Parent of two, learning about personal finance.',NULL,5,1,'2026-06-13 07:12:40.563957',NULL);
INSERT INTO "users" VALUES(22,'voduchuy','voduchuyuwu@gmail.com','$2b$10$xPch4zu3V6jrCo0BacsXrOl9ai1TvTxKtZjz6kE1HaFl1tBernaL.','Huy Võ Đức','',NULL,5,1,'2026-10-31 07:24:02.299462','2026-10-31 08:08:44.892039');
CREATE UNIQUE INDEX ix_categories_slug ON categories (slug);
CREATE UNIQUE INDEX ix_tags_slug ON tags (slug);
CREATE UNIQUE INDEX ix_users_email ON users (email);
CREATE UNIQUE INDEX ix_users_username ON users (username);
CREATE UNIQUE INDEX ix_documents_slug ON documents (slug);
CREATE INDEX ix_documents_created_at ON documents (created_at);
CREATE INDEX ix_documents_category_id ON documents (category_id);
CREATE INDEX ix_documents_status_published ON documents (status, published_at);
CREATE INDEX ix_documents_status ON documents (status);
CREATE INDEX ix_documents_published_at ON documents (published_at);
CREATE INDEX ix_documents_author_id ON documents (author_id);
CREATE INDEX ix_reports_status ON reports (status);
CREATE INDEX ix_audit_logs_timestamp ON audit_logs (timestamp);
CREATE INDEX ix_audit_logs_action ON audit_logs (action);
CREATE INDEX ix_comments_status ON comments (status);
CREATE INDEX ix_comments_document_id ON comments (document_id);
CREATE INDEX ix_comments_created_at ON comments (created_at);
CREATE INDEX ix_comments_user_id ON comments (user_id);
CREATE INDEX ix_search_click_logs_event_type ON search_click_logs (event_type);
CREATE INDEX ix_search_click_logs_timestamp ON search_click_logs (timestamp);
CREATE INDEX ix_search_click_logs_clicked_doc_id ON search_click_logs (clicked_doc_id);
CREATE INDEX ix_search_click_logs_query_string ON search_click_logs (query_string);
CREATE INDEX ix_search_click_logs_user_id ON search_click_logs (user_id);
CREATE INDEX ix_document_views_document_id ON document_views (document_id);
CREATE INDEX ix_document_views_timestamp ON document_views (timestamp);
COMMIT;