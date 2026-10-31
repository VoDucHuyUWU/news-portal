"""Seed articles: Technology and Science. Original explanatory texts written for this project."""

ARTICLES = [
    {
        "category": "technology", "author": "lan_pham",
        "title": "Passkeys explained: how they replace passwords",
        "summary": "Passkeys let you sign in with your fingerprint, face or device PIN instead of a password. Here is what happens behind the scenes and why they resist phishing.",
        "tags": ["Cybersecurity", "Privacy", "Internet"],
        "body": """A passkey is a pair of cryptographic keys created for one website or app. The public key is stored by the service, while the private key never leaves your device or your password manager. When you sign in, the service sends a challenge, your device signs it with the private key, and the service checks the signature with the public key.

You unlock the private key with whatever you already use to unlock your phone or laptop: a fingerprint, your face or a PIN. That local check is not sent to the website. The site only learns that a valid signature arrived.

## Why passkeys stop phishing

A password can be typed into a fake login page. A passkey cannot, because it is bound to the real domain name. If a copycat site asks for a signature, your device simply has no passkey for that address.

There is also nothing useful to steal from the server. A database of public keys does not let an attacker sign in anywhere.

## What to keep in mind

Passkeys sync through your platform account or password manager, so protect that account well and keep a recovery method up to date. Many sites still keep a password as a fallback during the transition, which means the old weak point remains until you remove it.""",
    },
    {
        "category": "technology", "author": "daniel_okafor",
        "title": "What actually happens when you type a web address",
        "summary": "Between pressing Enter and seeing a page, your browser looks up an address, opens a secure connection and downloads dozens of files. A step-by-step walk through.",
        "tags": ["Internet", "Software"],
        "body": """Typing a web address starts a short chain of conversations between computers. First, your browser needs a numeric IP address for the name you typed. It asks the Domain Name System, a distributed directory that maps names to addresses. Answers are cached at several levels, so popular sites resolve almost instantly.

Next, the browser opens a connection to that address and negotiates encryption using TLS. The server presents a certificate signed by an authority your device trusts, which proves you reached the real owner of the domain and not an impostor. The padlock icon summarises that check.

## Requesting the page

With a secure channel in place, the browser sends an HTTP request for the page. The server replies with HTML, the skeleton of the page. While reading it, the browser discovers stylesheets, scripts, fonts and images and requests them too, often in parallel over the same connection.

## Building what you see

The browser turns HTML into a tree of elements, applies styles, calculates the layout and paints pixels on the screen. Scripts can change the page afterwards, which is why some sites keep loading content as you scroll. All of this usually happens in well under a few seconds.""",
    },
    {
        "category": "technology", "author": "clara_jensen",
        "title": "Large language models, in plain words",
        "summary": "Chat assistants are built on models trained to predict the next piece of text. Understanding that one idea explains both their strengths and their mistakes.",
        "tags": ["Artificial Intelligence", "Software"],
        "body": """A large language model is a neural network trained on a very large collection of text. During training it repeatedly sees a passage with the next word hidden and adjusts billions of internal numbers so that its guess becomes more likely to be right. Text is split into tokens, which can be whole words or fragments of words.

After enough training, predicting the next token well requires picking up grammar, facts, styles of argument and patterns of reasoning that appear in the data. Developers then fine-tune the model on examples of helpful conversations and use human feedback to steer its behaviour.

## Why they sometimes make things up

The model produces the most plausible continuation, not a looked-up answer. When the training data is thin or the question is unusual, a plausible-sounding but wrong statement can come out. Connecting the model to search or to a company's own documents helps, because the answer can then be grounded in sources you can check.

## Using them well

Give clear context, ask for sources or reasoning, and verify anything important. Treat the output as a capable first draft rather than a final authority.""",
    },
    {
        "category": "technology", "author": "tomas_silva",
        "title": "Why your phone battery wears out, and how to slow it down",
        "summary": "Lithium-ion batteries lose capacity with every cycle, and heat speeds the process up. A few habits can noticeably extend their useful life.",
        "tags": ["Hardware", "Energy"],
        "body": """Almost every phone uses a lithium-ion battery. Charging pushes lithium ions into the graphite of one electrode; using the phone lets them flow back. Each cycle causes tiny side reactions that consume some lithium and build up layers on the electrodes, so the battery slowly holds less charge.

Two conditions accelerate this ageing more than anything else: high temperature and spending long periods at a very high or very low state of charge. A battery left at full charge in a hot car ages much faster than one kept cool at half charge.

## Habits that help

Avoid leaving the phone in direct sun or charging it under a pillow. Fast charging is convenient and generally safe, but it produces more heat, so slower charging overnight is gentler. Many phones now offer an optimised or limited charging option that pauses at around 80 percent until you need it; turning it on is one of the easiest wins.

## When to replace it

A worn battery is normal, not a defect. If the phone shuts down unexpectedly or lasts only part of a day, replacing the battery is usually far cheaper, and less wasteful, than replacing the whole device.""",
    },
    {
        "category": "technology", "author": "lan_pham",
        "title": "Two-factor authentication: which method should you choose?",
        "summary": "Text-message codes, authenticator apps and security keys all add a second step to logging in, but they are not equally strong.",
        "tags": ["Cybersecurity", "Privacy"],
        "body": """Two-factor authentication asks for something in addition to your password, so a leaked password alone is not enough to take over your account. The second factor comes in several forms, and the differences matter.

SMS codes are the most familiar. They are far better than nothing, but they can be intercepted through SIM-swap fraud, where a criminal convinces a carrier to move your number to their card. They can also be typed into a convincing phishing page.

## Authenticator apps

Apps that generate six-digit codes every 30 seconds are not tied to your phone number, which removes the SIM-swap risk. Push-notification apps are convenient, but be wary of approving a request you did not start; attackers sometimes send repeated prompts hoping someone taps "approve" to make them stop.

## Security keys and passkeys

Hardware security keys and passkeys check the website's real address before responding, which makes them resistant to phishing. For email, banking and your password manager, they are the strongest option most people can use.

Whatever you choose, save the recovery codes somewhere safe and offline. Losing your only second factor is the most common way people lock themselves out.""",
    },
    {
        "category": "technology", "author": "daniel_okafor",
        "title": "Open-source software runs the world. Who maintains it?",
        "summary": "From web servers to the libraries inside your phone apps, open-source code is everywhere. Much of it depends on a small number of volunteers.",
        "tags": ["Software", "Careers"],
        "body": """Open-source software is code that anyone can read, modify and share under a licence that permits it. It powers most web servers, the Linux kernel inside Android phones, programming languages, databases and countless small libraries that applications quietly depend on.

A typical modern app includes hundreds of open-source packages, each of which may depend on others. That web of dependencies lets developers build quickly, but it also means a bug or vulnerability deep in the chain can affect thousands of products at once.

## The maintenance gap

Popular projects are sometimes maintained by one or two people in their spare time. Reviewing contributions, answering issues and fixing security problems is real work, and burnout is common. Several well-known security incidents have traced back to under-resourced projects that many companies relied on without contributing back.

## How the picture is changing

Foundations, company sponsorship programmes and paid maintainer roles have grown. Organisations increasingly track which open-source components they use and fund the critical ones. For individual developers, contributing documentation, tests or bug reports is a practical way to start, and it is also a well-recognised way to build a public portfolio.""",
    },
    {
        "category": "technology", "author": "clara_jensen",
        "title": "How recommendation algorithms decide what you see",
        "summary": "Video, shopping and music platforms rank content by predicting what you will engage with. Knowing the signals they use gives you more control.",
        "tags": ["Artificial Intelligence", "Internet", "Privacy"],
        "body": """Recommendation systems start from a simple problem: there is far more content than anyone could browse, so something has to choose. Most platforms first gather a large pool of candidate items, then rank them with a model that predicts how likely you are to click, watch, buy or keep scrolling.

The signals come from your behaviour and from people similar to you. Watch time, likes, skips, searches, purchase history and even how long you pause on an item all feed the predictions. Collaborative filtering adds a simple idea: people who liked the same things in the past tend to like similar things in the future.

## Side effects

Optimising for engagement can favour content that provokes strong reactions, and it can narrow what you see over time. Platforms counter this with diversity rules and quality signals, with mixed success.

## Steering your own feed

Use the "not interested" and "don't recommend" options; they are real signals. Clear or pause watch and search history if you want a fresh start. Following topics deliberately, rather than only reacting to what appears, also shifts what the system believes you want.""",
    },
    {
        "category": "technology", "author": "tomas_silva",
        "title": "Cloud storage or local backups? Building a sensible backup plan",
        "summary": "Sync is not the same as backup. The 3-2-1 rule offers a simple way to protect photos and documents against theft, failure and mistakes.",
        "tags": ["Software", "Hardware", "Privacy"],
        "body": """Many people assume their files are backed up because they sync to a cloud service. Sync keeps copies identical across devices, which also means that a deleted or encrypted file can disappear everywhere at once. A backup is a separate copy you can restore from, ideally including older versions.

A widely used guideline is the 3-2-1 rule: keep three copies of important data, on two different types of storage, with one copy off-site. For a household that might mean the files on your laptop, an external drive at home and a cloud backup service.

## Choosing the pieces

External drives are cheap and fast to restore from, but they fail, get lost and are vulnerable to fire or theft. Cloud backup protects against local disasters and keeps file history, but restoring a large library over the internet can take time.

## The step most people skip

Test a restore. Pick a few files every few months and recover them from each backup. A backup you have never restored is only a hope. Also turn on version history where it is available, because it is the main defence against ransomware and accidental overwrites.""",
    },
    {
        "category": "technology", "author": "lan_pham",
        "title": "Spotting phishing messages before they spot you",
        "summary": "Phishing relies on urgency and imitation. Learning a handful of warning signs, and one golden rule, prevents most account takeovers.",
        "tags": ["Cybersecurity", "Internet"],
        "body": """Phishing messages pretend to come from someone you trust, such as a bank, a delivery company, a colleague or a streaming service, and try to get you to click a link, open an attachment or share information. They arrive by email, text message, social media and phone calls.

The strongest warning sign is pressure. Messages that say your account will be closed today, that a payment failed or that your manager needs gift cards urgently are designed to make you act before you think.

## Practical checks

Look at the actual sender address and the real destination of links, not the display name. Watch for small misspellings in domain names. Be suspicious of unexpected attachments, especially archives and documents that ask you to enable macros. Legitimate organisations rarely ask for passwords or one-time codes.

## The golden rule

Do not use the contact details in the message. If something seems urgent, open the app yourself or type the known website address, or call the number printed on your card. Report the message to your IT team or the impersonated company. Using passkeys or a password manager also helps, because they will not fill in credentials on a fake site.""",
    },
    {
        "category": "technology", "author": "daniel_okafor",
        "title": "What a chip shortage teaches us about supply chains",
        "summary": "When semiconductors ran short, cars and consoles were delayed worldwide. The episode revealed how concentrated and slow-moving chip production is.",
        "tags": ["Hardware", "Economics"],
        "body": """Semiconductors are in almost everything with a battery or a plug, from cars and washing machines to medical devices. When demand for electronics surged and factories faced disruptions in the early 2020s, shortages rippled across industries that had never thought of themselves as chip buyers.

Making chips is unusually hard to scale quickly. A modern fabrication plant costs many billions of dollars and takes years to build and equip. The most advanced manufacturing is concentrated in a few companies and regions, and some of the specialised machines involved come from a single supplier.

## Why cars were hit hard

Car makers often used just-in-time ordering and older, cheaper chips. When they cut orders early in the pandemic, chip factories reassigned capacity to consumer electronics. When car demand returned, the capacity was not there, and a missing part worth a few dollars could leave a vehicle unfinished.

## Lessons businesses took away

Companies have since increased buffer stocks for critical parts, signed longer-term supply agreements and designed products that can use alternative components. Governments in several regions have also funded new factories to reduce dependence on a small number of locations.""",
    },
    {
        "category": "science", "author": "clara_jensen",
        "title": "Why the sky is blue and sunsets are red",
        "summary": "Sunlight contains every colour, but air molecules scatter short blue wavelengths far more than red ones. The same effect paints the evening sky.",
        "tags": ["Physics"],
        "body": """Sunlight looks white, but it is a mixture of all visible colours. As it passes through the atmosphere, it meets nitrogen and oxygen molecules that are much smaller than the wavelength of light. These molecules scatter light in all directions, and they scatter shorter wavelengths far more strongly than longer ones. This is called Rayleigh scattering.

Blue light has a short wavelength, so it is scattered across the whole sky and reaches your eyes from every direction. That is why the sky looks blue during the day. Violet is scattered even more, but sunlight contains less of it, some is absorbed high in the atmosphere, and our eyes are less sensitive to it.

## Red and orange evenings

When the Sun is low, its light travels through much more air before reaching you. Most of the blue is scattered out of the direct beam along the way, leaving the longer orange and red wavelengths. Dust, smoke and other particles can intensify the colours.

The same physics explains why distant mountains look bluish and why the Moon's sky, with no atmosphere, is black even in daylight.""",
    },
    {
        "category": "science", "author": "tomas_silva",
        "title": "How vaccines train the immune system",
        "summary": "Vaccines show the immune system a harmless preview of a germ so it can respond faster to the real thing. Different vaccine types deliver that preview in different ways.",
        "tags": ["Biology", "Medicine", "Public Health"],
        "body": """Your immune system learns from experience. The first time it meets a new germ, it takes days to produce antibodies and specialised cells that target it. During that delay, the infection can make you seriously ill. Afterwards, memory cells remain, ready to respond much faster next time.

A vaccine provides that first experience without the disease. It presents the immune system with a recognisable piece of the pathogen, called an antigen, or with instructions to make one.

## Different ways to deliver the preview

Inactivated vaccines use killed germs. Live attenuated vaccines use weakened versions that cannot cause normal illness in healthy people. Subunit vaccines use only selected proteins. mRNA vaccines deliver short-lived instructions that let your own cells briefly make a harmless protein, which the immune system then learns to recognise.

## Why boosters and coverage matter

Immune memory can fade, and some viruses change over time, so certain vaccines need boosters or updated versions. When enough people in a community are immune, a germ struggles to spread, which also protects those who cannot be vaccinated, such as very young babies or people with weakened immune systems.""",
    },
    {
        "category": "science", "author": "daniel_okafor",
        "title": "Black holes without the jargon",
        "summary": "A black hole is a region where gravity is so strong that not even light can escape. Here is how they form and how astronomers study something invisible.",
        "tags": ["Space", "Physics"],
        "body": """Gravity depends on how much mass is packed into how small a space. Squeeze enough mass into a small enough region and the escape speed exceeds the speed of light. The boundary where that happens is the event horizon. Nothing that crosses it, not even light, can come back out.

Stellar black holes form when very massive stars run out of fuel. The core can no longer support itself and collapses, often while the outer layers explode as a supernova. Supermassive black holes, millions or billions of times the mass of the Sun, sit at the centres of most large galaxies, including our own Milky Way.

## Seeing the invisible

Astronomers detect black holes by their effects. Gas swirling towards them heats up and glows brightly in X-rays. Stars near the centre of our galaxy move in tight, fast orbits around an unseen mass. When two black holes merge, they send out gravitational waves that detectors on Earth can measure.

Radio telescopes linked across the planet have even produced images of the glowing ring of material around the shadow of a black hole, a result that matched the predictions of general relativity.""",
    },
    {
        "category": "science", "author": "lan_pham",
        "title": "CRISPR gene editing: what it can and cannot do",
        "summary": "CRISPR lets scientists cut DNA at chosen locations with remarkable precision. It is transforming research and starting to reach patients, but it has limits.",
        "tags": ["Biology", "Research", "Medicine"],
        "body": """CRISPR began as part of a bacterial immune system. Bacteria store snippets of viral DNA and use them to guide an enzyme, most famously Cas9, to cut matching viral genes. Researchers realised the system could be reprogrammed: supply a short guide RNA that matches any DNA sequence, and the enzyme will cut there.

After the cut, the cell repairs its DNA. Sometimes the repair disables the gene, which is useful for studying what a gene does. With a template provided, the repair can also insert or correct a sequence. Newer variants, such as base editors and prime editors, change individual letters of DNA without making a full double-strand cut.

## From the lab to patients

CRISPR is now a standard laboratory tool for studying genes in cells, plants and animals. The first therapies approved for patients edit a person's own blood stem cells outside the body to treat certain inherited blood disorders.

## Limits and open questions

Delivering editors to the right cells inside the body remains difficult. Unintended edits elsewhere in the genome must be carefully measured. Editing embryos, where changes would be inherited, raises ethical concerns that most countries currently address with strict limits or bans.""",
    },
    {
        "category": "science", "author": "clara_jensen",
        "title": "How scientists date ancient objects with carbon-14",
        "summary": "Living things absorb a trace of radioactive carbon that decays at a steady rate after death. Measuring what is left reveals an age of up to around 50,000 years.",
        "tags": ["Chemistry", "Research"],
        "body": """Most carbon atoms are carbon-12, but a tiny fraction is carbon-14, a radioactive form created when cosmic rays strike nitrogen in the upper atmosphere. Plants take up carbon-14 along with ordinary carbon during photosynthesis, and animals take it in by eating plants. While an organism is alive, its ratio of carbon-14 to carbon-12 stays close to that of the atmosphere.

When the organism dies, it stops taking in new carbon, and the carbon-14 it contains decays steadily. Its half-life is about 5,730 years: after that time, half of the original carbon-14 remains; after twice that time, a quarter remains, and so on.

## From measurement to calendar years

Modern laboratories count carbon-14 atoms directly with accelerator mass spectrometry, which needs only a small sample. Because atmospheric carbon-14 has varied over time, raw results are calibrated against records from tree rings, cave formations and sediments with known ages.

## What it can date

The method works on once-living material such as wood, bone, charcoal, shells and cloth. After roughly 50,000 years, too little carbon-14 remains to measure reliably, so older objects and rocks are dated with other radioactive isotopes.""",
    },
    {
        "category": "science", "author": "tomas_silva",
        "title": "The life cycle of a star",
        "summary": "Stars are born in clouds of gas, shine by fusing hydrogen and end as white dwarfs, neutron stars or black holes. Their mass decides which path they take.",
        "tags": ["Space", "Physics"],
        "body": """Stars form inside cold clouds of gas and dust. When a dense region collapses under its own gravity, it heats up until hydrogen nuclei in the core begin to fuse into helium. The energy released pushes outward and balances gravity, and a stable star is born.

A star spends most of its life in this hydrogen-burning phase, called the main sequence. Mass sets the pace: massive stars burn hot and bright and may last only a few million years, while small red dwarfs can shine for far longer than the current age of the universe. The Sun is roughly halfway through a main-sequence life of about ten billion years.

## Endings depend on mass

When the core runs out of hydrogen, a star like the Sun swells into a red giant, sheds its outer layers as a glowing nebula and leaves behind a dense white dwarf. Much more massive stars fuse heavier elements in layers until the core collapses, triggering a supernova. What remains is either a neutron star or, for the heaviest cores, a black hole.

Supernovae scatter elements such as oxygen, carbon and iron into space, where they become part of new stars, planets and, eventually, living things.""",
    },
    {
        "category": "science", "author": "daniel_okafor",
        "title": "Why peer review matters, and where it falls short",
        "summary": "Before most research is published, other experts scrutinise it. Peer review catches many problems, but it was never designed to guarantee that a result is true.",
        "tags": ["Research", "Universities"],
        "body": """When researchers submit a paper to a journal, an editor usually sends it to a few independent experts in the field. These reviewers assess whether the question is important, the methods are appropriate, the analysis supports the conclusions and the work fits into existing knowledge. They often request changes or additional experiments before publication.

Peer review improves papers and filters out many weak studies. It also helps readers who are not specialists, because publication in a reviewed journal signals that at least some experts found the work credible.

## Its limits

Reviewers rarely have access to raw data or the time to repeat experiments, so fabricated results and subtle errors can slip through. Reviews can be slow, and reviewers can be biased towards familiar ideas or well-known institutions. Positive results are also more likely to be published than null results, which can distort the overall picture.

## Ongoing improvements

Many journals now encourage or require sharing data and code, and some publish reviews alongside papers. Preprints allow faster sharing before review, though readers should treat them as preliminary. Ultimately, confidence comes from independent replication, not from a single published study.""",
    },
    {
        "category": "science", "author": "lan_pham",
        "title": "Tardigrades: the toughest animals on Earth",
        "summary": "These half-millimetre animals survive freezing, boiling, radiation and even the vacuum of space by entering a state of suspended animation.",
        "tags": ["Biology", "Wildlife"],
        "body": """Tardigrades, also known as water bears or moss piglets, are tiny eight-legged animals usually less than a millimetre long. They live almost everywhere there is moisture, from garden moss and lichen to deep-sea sediments and mountain tops.

Their fame comes from extreme resilience. When their environment dries out, many species curl into a compact form called a tun and slow their metabolism to almost nothing. In this state they can endure temperatures close to absolute zero, brief heating far above boiling, high doses of radiation and pressures greater than those at the bottom of the ocean. Some have survived exposure to space on research missions and revived afterwards.

## How they do it

As they dry out, tardigrades produce protective molecules, including special proteins that form glass-like structures around cell contents, preventing them from falling apart. One protein discovered in a tardigrade species appears to shield DNA from radiation damage.

## Why scientists care

Understanding these mechanisms could help preserve vaccines and medicines without refrigeration and protect cells in other settings. Tardigrades are not indestructible, though: in their active state they are as vulnerable as any other small animal.""",
    },
    {
        "category": "science", "author": "clara_jensen",
        "title": "How GPS knows where you are, relativity included",
        "summary": "Your phone finds its position by timing signals from satellites. The clocks are so precise that Einstein's theories have to be built into the system.",
        "tags": ["Physics", "Space", "Hardware"],
        "body": """The Global Positioning System is a constellation of satellites orbiting about 20,000 kilometres above Earth. Each satellite carries atomic clocks and continuously broadcasts its position and the exact time the signal was sent.

Your receiver measures when each signal arrives. Because radio waves travel at the speed of light, the delay tells it how far away each satellite is. With distances to at least four satellites, the receiver can solve for its latitude, longitude, altitude and the error in its own, much cheaper, clock.

## Where relativity comes in

Timing errors matter enormously: a billionth of a second corresponds to about 30 centimetres. Special relativity says the fast-moving satellite clocks tick slightly slower than clocks on the ground. General relativity says clocks higher up in a weaker gravitational field tick slightly faster. The combined effect is that satellite clocks would gain roughly 38 microseconds per day. Left uncorrected, positions would drift by kilometres within a day, so the clocks are adjusted to compensate.

## Beyond GPS

Phones also use other satellite systems, nearby Wi-Fi networks and motion sensors, which speeds up the first fix and improves accuracy in cities where tall buildings block the sky.""",
    },
    {
        "category": "science", "author": "tomas_silva",
        "title": "What makes a good scientific experiment",
        "summary": "Control groups, randomisation and blinding are not bureaucratic rituals. Each one removes a specific way that we fool ourselves.",
        "tags": ["Research", "Learning"],
        "body": """A good experiment is designed so that the result can only be explained by the thing being tested. That sounds simple, but many alternative explanations hide in ordinary situations, and the standard tools of experimental design exist to rule them out one by one.

A control group receives everything except the treatment. Without it, improvements might be due to time passing, natural recovery or simply being observed. Random assignment to groups ensures that differences between people, such as age or health, are spread evenly rather than chosen, consciously or not, by the researcher.

## Blinding and placebo

When participants know they are receiving a treatment, expectations can change how they feel and report results. When researchers know, they may measure or interpret outcomes differently. Blinding one or both sides, often with a placebo, removes these influences.

## Planning before looking

Deciding the main outcome and the analysis in advance, and calculating how many participants are needed, prevents searching through data until something looks significant. Many studies now pre-register these plans publicly. Finally, an exciting result should be repeated by others before it is trusted: replication is the strongest test of all.""",
    },
]
