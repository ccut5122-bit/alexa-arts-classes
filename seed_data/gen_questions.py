import json


def q(question_id, subject_id, chapter_id, text, options, correct, diff="medium", year=0, source="JAC PYQ", marks=1, nm=0.25, tags=None, expl=""):
    assert correct in [o["id"] for o in options], f"{question_id} correct option invalid"
    return {
        "_id": question_id, "subjectId": subject_id, "chapterId": chapter_id,
        "type": "mcq", "questionText": text, "questionTextHindi": text,
        "options": options, "correctOption": correct, "explanation": expl,
        "explanationHindi": expl, "difficulty": diff, "tags": tags or [],
        "source": source, "year": year, "marks": marks, "negativeMarks": nm,
    }


Q = []
def add(*args, **kw):
    Q.append(q(*args, **kw))

# ============ HISTORY ============
# hist_ch1: +8 (have 2)
add("q_hist_7","history","hist_ch1","What was the primary purpose for which writing first emerged in Sumer?",
    [{"id":"a","text":"Religious hymns"},{"id":"b","text":"Counting produce and taxes"},{"id":"c","text":"Writing poetry"},{"id":"d","text":"Recording wars"}],"b","easy","",
    expl="Writing began in Sumer around 3200 BCE for keeping records of produce and taxes.")
add("q_hist_8","history","hist_ch1","Which city is considered one of the earliest cities of the world?",
    [{"id":"a","text":"Babylon"},{"id":"b","text":"Uruk"},{"id":"c","text":"Nineveh"},{"id":"d","text":"Persepolis"}],"b","easy",
    expl="Uruk, a Mesopotamian city, is among the earliest cities of the world.")
add("q_hist_9","history","hist_ch1","The two rivers of Mesopotamia are the Tigris and the:",
    [{"id":"a","text":"Nile"},{"id":"b","text":"Euphrates"},{"id":"c","text":"Indus"},{"id":"d","text":"Danube"}],"b","easy",
    expl="Mesopotamia lay between the Tigris and the Euphrates.")
add("q_hist_10","history","hist_ch1","What is the Greek meaning of the word 'Mesopotamia'?",
    [{"id":"a","text":"Land between rivers"},{"id":"b","text":"Land of sand"},{"id":"c","text":"Cradle of gods"},{"id":"d","text":"Land of writing"}],"a","easy",
    expl="Mesopotamia is Greek for 'land between two rivers'.")
add("q_hist_11","history","hist_ch1","Scribes in Mesopotamian cities were mainly:",
    [{"id":"a","text":"Warriors"},{"id":"b","text":"Record keepers and writers"},{"id":"c","text":"Farmers"},{"id":"d","text":"Traders only"}],"b","medium",
    expl="Scribes were literate people who kept records and wrote documents.")
add("q_hist_12","history","hist_ch1","Mesopotamian city-states grew mainly because of:",
    [{"id":"a","text":"Mining"},{"id":"b","text":"Trade and agriculture"},{"id":"c","text":"Factory production"},{"id":"d","text":"Tourism"}],"b","medium",
    expl="Agriculture on fertile plains and trade made Mesopotamian cities prosperous.")
add("q_hist_13","history","hist_ch1","Which structure served as the centre of religion and economy in Mesopotamian cities?",
    [{"id":"a","text":"Colosseum"},{"id":"b","text":"Ziggurat"},{"id":"c","text":"Pyramid"},{"id":"d","text":"Aqueduct"}],"b","medium",
    expl="Temples called ziggurats were centres of religion and economy.")
add("q_hist_14","history","hist_ch1","The script of the Sumerians is known as:",
    [{"id":"a","text":"Hieroglyphics"},{"id":"b","text":"Cuneiform"},{"id":"c","text":"Brahmi"},{"id":"d","text":"Linear B"}],"b","medium",
    expl="Cuneiform, a wedge-shaped script, was used by the Sumerians.")

# hist_ch2: +7 (have 1)
add("q_hist_15","history","hist_ch2","The Roman Empire at its height surrounded which sea?",
    [{"id":"a","text":"Black Sea"},{"id":"b","text":"Mediterranean Sea"},{"id":"c","text":"Red Sea"},{"id":"d","text":"Caspian Sea"}],"b","medium",
    expl="The Roman Empire sprawled around the Mediterranean Sea across three continents.")
add("q_hist_16","history","hist_ch2","Which ruler moved the capital of the Roman Empire to Byzantium (Constantinople)?",
    [{"id":"a","text":"Augustus"},{"id":"b","text":"Julius Caesar"},{"id":"c","text":"Constantine"},{"id":"d","text":"Nero"}],"c","medium",
    expl="Constantine shifted the capital to Byzantium, later called Constantinople.")
add("q_hist_17","history","hist_ch2","The Roman Emperor who established the Principate and became the first emperor was:",
    [{"id":"a","text":"Augustus"},{"id":"b","text":"Tiberius"},{"id":"c","text":"Hadrian"},{"id":"d","text":"Trajan"}],"a","medium",
    expl="Augustus (Octavian) established the Roman Empire under his rule in 27 BCE.")
add("q_hist_18","history","hist_ch2","The main language of the Roman Empire in the west was:",
    [{"id":"a","text":"Greek"},{"id":"b","text":"Latin"},{"id":"c","text":"Arabic"},{"id":"d","text":"Persian"}],"b","easy",
    expl="Latin was the official language of the western Roman Empire.")
add("q_hist_19","history","hist_ch2","Roman agriculture relied heavily on which type of labour?",
    [{"id":"a","text":"Free citizens"},{"id":"b","text":"Slaves"},{"id":"c","text":"Foreign mercenaries"},{"id":"d","text":"Machines"}],"b","medium",
    expl="The Roman economy depended greatly on slave labour on latifundia estates.")
add("q_hist_20","history","hist_ch2","The period of relative peace and prosperity in the Roman Empire is called the:",
    [{"id":"a","text":"Renaissance"},{"id":"b","text":"Pax Romana"},{"id":"c","text":"Golden Calf"},{"id":"d","text":"Dark Age"}],"b","medium",
    expl="Pax Romana, 'Roman Peace', was a time of relative stability.")
add("q_hist_21","history","hist_ch2","Which group of people travelled and traded across the Roman Empire and were later persecuted?",
    [{"id":"a","text":"Christians"},{"id":"b","text":"Vandals"},{"id":"c","text":"Huns"},{"id":"d","text":"Goths"}],"a","hard",
    expl="Christians faced persecution in early Roman times before Christianity was accepted.")

# hist_ch3: +6 (have 1)
add("q_hist_22","history","hist_ch3","The Mongols were primarily which kind of society?",
    [{"id":"a","text":"Agrarian"},{"id":"b","text":"Pastoral and nomadic"},{"id":"c","text":"Industrial"},{"id":"d","text":"Maritime"}],"b","easy",
    expl="The Mongols were nomadic pastoralists of the Central Asian steppe.")
add("q_hist_23","history","hist_ch3","Genghis Khan's original name was:",
    [{"id":"a","text":"Temujin"},{"id":"b","text":"Kublai"},{"id":"c","text":"Batu"},{"id":"d","text":"Ogedei"}],"a","hard",
    expl="Genghis Khan was born Temujin before taking the title Genghis Khan.")
add("q_hist_24","history","hist_ch3","The Mongol Empire was divided into four parts called:",
    [{"id":"a","text":"Provinces"},{"id":"b","text":"Khanates"},{"id":"c","text":"Sultanates"},{"id":"d","text":"Fiefs"}],"b","medium",
    expl="After Genghis Khan's death the empire split into four khanates.")
add("q_hist_25","history","hist_ch3","The great plain of Central Asia where Mongols lived is called the:",
    [{"id":"a","text":"Tundra"},{"id":"b","text":"Steppe"},{"id":"c","text":"Savanna"},{"id":"d","text":"Desert"}],"b","easy",
    expl="The grassland steppes of Central Asia were home to the Mongols.")
add("q_hist_26","history","hist_ch3","Which Mongol ruler conquered China and founded the Yuan dynasty?",
    [{"id":"a","text":"Genghis Khan"},{"id":"b","text":"Kublai Khan"},{"id":"c","text":"Batu Khan"},{"id":"d","text":"Hulegu"}],"b","medium",
    expl="Kublai Khan, grandson of Genghis, founded the Yuan dynasty in China.")
add("q_hist_27","history","hist_ch3","The principal occupation of the pastoral Mongols was:",
    [{"id":"a","text":"Farming wheat"},{"id":"b","text":"Herd rearing and hunting"},{"id":"c","text":"Ship building"},{"id":"d","text":"Textile weaving"}],"b","medium",
    expl="Mongols reared herds of horses, sheep and cattle and hunted game.")

# hist_ch4: +8 (have 1)
add("q_hist_28","history","hist_ch4","Which invention greatly contributed to the Industrial Revolution in Britain?",
    [{"id":"a","text":"Printing press"},{"id":"b","text":"Steam engine"},{"id":"c","text":"Telephone"},{"id":"d","text":"Electric motor"}],"b","medium",
    expl="James Watt's steam engine powered factories and transport during the Industrial Revolution.")
add("q_hist_29","history","hist_ch4","The Industrial Revolution began in which century?",
    [{"id":"a","text":"14th century"},{"id":"b","text":"16th century"},{"id":"c","text":"18th century"},{"id":"d","text":"20th century"}],"c","easy",
    expl="It began in Britain in the late eighteenth century.")
add("q_hist_30","history","hist_ch4","The first modern factory system developed in which industry?",
    [{"id":"a","text":"Iron and steel"},{"id":"b","text":"Textiles"},{"id":"c","text":"Railways"},{"id":"d","text":"Shipbuilding"}],"b","medium",
    expl="Cotton textile mills pioneered the modern factory system in Britain.")
add("q_hist_31","history","hist_ch4","The industrial working class came to be known as the:",
    [{"id":"a","text":"Gentry"},{"id":"b","text":"Proletariat"},{"id":"c","text":"Bourgeoisie"},{"id":"d","text":"Aristocracy"}],"b","medium",
    expl="Marx used 'proletariat' for the industrial working class.")
add("q_hist_32","history","hist_ch4","Transport by rail in Britain began after the invention of the:",
    [{"id":"a","text":"Loom"},{"id":"b","text":"Steam locomotive"},{"id":"c","text":"Spinning wheel"},{"id":"d","text":"Compass"}],"b","easy",
    expl="The steam locomotive (Stephenson) brought the railway age to Britain.")
add("q_hist_33","history","hist_ch4","Which country was the first to industrialise outside Britain in continental Europe?",
    [{"id":"a","text":"Italy"},{"id":"b","text":"Belgium"},{"id":"c","text":"Russia"},{"id":"d","text":"Spain"}],"b","hard",
    expl="Belgium industrialised early in the nineteenth century after Britain.")
add("q_hist_34","history","hist_ch4","The enclosure movement in Britain was related to:",
    [{"id":"a","text":"Religion"},{"id":"b","text":"Land and farming"},{"id":"c","text":"Education"},{"id":"d","text":"Trade"}],"b","medium",
    expl="Enclosures consolidated open fields into private farms, supplying labour for industry.")
add("q_hist_35","history","hist_ch4","Which classes benefited most from industrialisation?",
    [{"id":"a","text":"Factory workers"},{"id":"b","text":"Industrialists and merchants"},{"id":"c","text":"Serfs"},{"id":"d","text":"Clergy"}],"b","medium",
    expl="Business owners and traders accumulated wealth from industrial growth.")

# hist_ch5: +5 (have 1)
add("q_hist_36","history","hist_ch5","Which European power colonised Brazil?",
    [{"id":"a","text":"Spain"},{"id":"b","text":"Portugal"},{"id":"c","text":"France"},{"id":"d","text":"Britain"}],"b","medium",
    expl="Portugal claimed Brazil under the Treaty of Tordesillas.")
add("q_hist_37","history","hist_ch5","The Aztec civilisation at the time of Spanish conquest was centred in:",
    [{"id":"a","text":"Peru"},{"id":"b","text":"Mexico"},{"id":"c","text":"Brazil"},{"id":"d","text":"Chile"}],"b","medium",
    expl="The Aztecs dominated central Mexico with their capital Tenochtitlan.")
add("q_hist_38","history","hist_ch5","Which Inca ruler was captured by Francisco Pizarro?",
    [{"id":"a","text":"Montezuma"},{"id":"b","text":"Atahualpa"},{"id":"c","text":"Cuauhtemoc"},{"id":"d","text":"Moctezuma"}],"b","hard",
    expl="Pizarro captured the Inca emperor Atahualpa in Peru.")
add("q_hist_39","history","hist_ch5","Columbus' voyages were sponsored by which country?",
    [{"id":"a","text":"Portugal"},{"id":"b","text":"Spain"},{"id":"c","text":"England"},{"id":"d","text":"Netherlands"}],"b","easy",
    expl="Queen Isabella of Spain sponsored Columbus' voyages.")
add("q_hist_40","history","hist_ch5","The transfer of plants, animals and diseases between the New and Old Worlds is called the:",
    [{"id":"a","text":"Silk Road Trade"},{"id":"b","text":"Columbian Exchange"},{"id":"c","text":"Black Death"},{"id":"d","text":"Slave Triangle"}],"b","medium",
    expl="The Columbian Exchange moved crops, animals and germs across the Atlantic.")

# hist_ch6: +8 (have 0)
add("q_hist_41","history","hist_ch6","The Meiji Restoration of 1868 modernised which country?",
    [{"id":"a","text":"China"},{"id":"b","text":"Japan"},{"id":"c","text":"Korea"},{"id":"d","text":"Vietnam"}],"b","easy",
    expl="Japan modernised rapidly after the Meiji Restoration of 1868.")
add("q_hist_42","history","hist_ch6","Chinese society considered which class lowest in the traditional hierarchy?",
    [{"id":"a","text":"Scholars"},{"id":"b","text":"Merchants"},{"id":"c","text":"Peasants"},{"id":"d","text":"Officials"}],"b","medium",
    expl="In Confucian order merchants ranked low; scholars and officials ranked high.")
add("q_hist_43","history","hist_ch6","The Opium Wars were fought between China and:",
    [{"id":"a","text":"Japan"},{"id":"b","text":"Britain"},{"id":"c","text":"Russia"},{"id":"d","text":"France"}],"b","medium",
    expl="Britain fought the Opium Wars (1839-42, 1856-60) to force open Chinese trade.")
add("q_hist_44","history","hist_ch6","The Meiji government slogan for industrialisation was:",
    [{"id":"a","text":"Rich country, strong army"},{"id":"b","text":"Liberty and equality"},{"id":"c","text":"One empire, one law"},{"id":"d","text":"Land to the tiller"}],"a","hard",
    expl="'Fukoku kyohei' — rich country, strong army — guided Japanese modernisation.")
add("q_hist_45","history","hist_ch6","Which dynasty ruled China when it was overthrown in 1911?",
    [{"id":"a","text":"Ming"},{"id":"b","text":"Tang"},{"id":"c","text":"Qing"},{"id":"d","text":"Song"}],"c","medium",
    expl="The Qing (Manchu) dynasty was overthrown in the 1911 revolution.")
add("q_hist_46","history","hist_ch6","The Chinese exam system that selected officials was based on:",
    [{"id":"a","text":"Military skill"},{"id":"b","text":"Confucian learning"},{"id":"c","text":"Trade wealth"},{"id":"d","text":"Noble birth"}],"b","medium",
    expl="Imperial China selected officials through examinations testing Confucian classics.")
add("q_hist_47","history","hist_ch6","Japan's period of isolation from the outside world was called:",
    [{"id":"a","text":"Shogunate only"},{"id":"b","text":"Sakoku"},{"id":"c","text":"Kami"},{"id":"d","text":"Bushido"}],"b","hard",
    expl="Sakoku was the Tokugawa policy of national isolation.")
add("q_hist_48","history","hist_ch6","The samurai class in Japan lived by a code of honour called:",
    [{"id":"a","text":"Bushido"},{"id":"b","text":"Shinto"},{"id":"c","text":"Kabuki"},{"id":"d","text":"Haiku"}],"a","medium",
    expl="Bushido, the 'way of the warrior', governed samurai conduct.")

# ============ POLITICAL SCIENCE ============
# pol_ch1: +8 (have 2)
add("q_pol_7","political_science","pol_ch1","The Constitution of India was adopted on:",
    [{"id":"a","text":"26 January 1948"},{"id":"b","text":"26 November 1949"},{"id":"c","text":"15 August 1947"},{"id":"d","text":"26 January 1950"}],"b","easy",
    expl="The Constitution was adopted on 26 November 1949 and came into force on 26 January 1950.")
add("q_pol_8","political_science","pol_ch1","The Constituent Assembly first met on:",
    [{"id":"a","text":"15 August 1947"},{"id":"b","text":"9 December 1946"},{"id":"c","text":"26 January 1950"},{"id":"d","text":"20 February 1947"}],"b","medium",
    expl="The Constituent Assembly held its first meeting on 9 December 1946.")
add("q_pol_9","political_science","pol_ch1","The Drafting Committee of the Constitution was headed by:",
    [{"id":"a","text":"Jawaharlal Nehru"},{"id":"b","text":"Dr. B.R. Ambedkar"},{"id":"c","text":"Rajendra Prasad"},{"id":"d","text":"Sardar Patel"}],"b","easy",
    expl="Dr. B.R. Ambedkar chaired the Drafting Committee.")
add("q_pol_10","political_science","pol_ch1","Who was the President of the Constituent Assembly?",
    [{"id":"a","text":"Dr. Rajendra Prasad"},{"id":"b","text":"Dr. B.R. Ambedkar"},{"id":"c","text":"Jawaharlal Nehru"},{"id":"d","text":"C. Rajagopalachari"}],"a","medium",
    expl="Dr. Rajendra Prasad was the permanent President of the Constituent Assembly.")
add("q_pol_11","political_science","pol_ch1","The Constitution declares India as a:",
    [{"id":"a","text":"Union of States"},{"id":"b","text":"Confederation"},{"id":"c","text":"Federation only"},{"id":"d","text":"Unitary state only"}],"a","medium",
    expl="Article 1 declares India as a 'Union of States'.")
add("q_pol_12","political_science","pol_ch1","The number of Constituent Assembly members who signed the Constitution was about:",
    [{"id":"a","text":"100"},{"id":"b","text":"201"},{"id":"c","text":"284"},{"id":"d","text":"500"}],"c","hard",
    expl="About 284 members signed the final document.")
add("q_pol_13","political_science","pol_ch1","The Constitution of India is:",
    [{"id":"a","text":"Flexible (like UK)"},{"id":"b","text":"Rigid (like USA)"},{"id":"c","text":"Partly rigid, partly flexible"},{"id":"d","text":"Neither rigid nor flexible"}],"c","medium",
    expl="The Indian Constitution combines rigidity and flexibility in amendment procedures.")
add("q_pol_14","political_science","pol_ch1","The idea of the Constitution was given concrete shape through which process?",
    [{"id":"a","text":"British Act"},{"id":"b","text":"Constituent Assembly deliberations"},{"id":"c","text":"Royal decree"},{"id":"d","text":"Public referendum"}],"b","easy",
    expl="The Constitution emerged from two years of Constituent Assembly deliberations.")

# pol_ch2: +9 (have 1)
add("q_pol_15","political_science","pol_ch2","How many Fundamental Rights are granted by the Indian Constitution (originally)?",
    [{"id":"a","text":"Five"},{"id":"b","text":"Seven"},{"id":"c","text":"Six"},{"id":"d","text":"Eight"}],"b","medium",
    expl="Originally seven Fundamental Rights were listed; property was later removed, leaving six.")
add("q_pol_16","political_science","pol_ch2","Right to Property was removed as a Fundamental Right by which Amendment?",
    [{"id":"a","text":"42nd"},{"id":"b","text":"44th"},{"id":"c","text":"52nd"},{"id":"d","text":"73rd"}],"b","hard",
    expl="The 44th Amendment (1978) removed the Right to Property as a Fundamental Right.")
add("q_pol_17","political_science","pol_ch2","Article 17 abolishes:",
    [{"id":"a","text":"Untouchability"},{"id":"b","text":"Child labour"},{"id":"c","text":"Sati"},{"id":"d","text":"Bonded labour"}],"a","medium",
    expl="Article 17 abolishes untouchability in all forms.")
add("q_pol_18","political_science","pol_ch2","Which Article prohibits discrimination on grounds of religion, race, caste, sex or place of birth?",
    [{"id":"a","text":"Article 14"},{"id":"b","text":"Article 15"},{"id":"c","text":"Article 19"},{"id":"d","text":"Article 25"}],"b","medium",
    expl="Article 15 prohibits discrimination on specified grounds.")
add("q_pol_19","political_science","pol_ch2","Equality before law is guaranteed under Article:",
    [{"id":"a","text":"14"},{"id":"b","text":"15"},{"id":"c","text":"16"},{"id":"d","text":"18"}],"a","easy",
    expl="Article 14 guarantees equality before the law and equal protection of laws.")
add("q_pol_20","political_science","pol_ch2","The Right to Constitutional Remedies is also called:",
    [{"id":"a","text":"Right to Life"},{"id":"b","text":"Heart and Soul of the Constitution"},{"id":"c","text":"Right to Vote"},{"id":"d","text":"Right to Work"}],"b","medium",
    expl="Article 32 enabling judicial remedy is called the heart and soul of the Constitution.")
add("q_pol_21","political_science","pol_ch2","Cultural and Educational Rights are provided under Articles:",
    [{"id":"a","text":"14-18"},{"id":"b","text":"19-22"},{"id":"c","text":"23-24"},{"id":"d","text":"29-30"}],"d","medium",
    expl="Articles 29-30 protect cultural and educational rights of minorities.")
add("q_pol_22","political_science","pol_ch2","Fundamental Rights can be suspended or restricted during:",
    [{"id":"a","text":"Elections"},{"id":"b","text":"National Emergency"},{"id":"c","text":"Bonded labour"},{"id":"d","text":"General elections"}],"b","easy",
    expl="During National Emergency, some Fundamental Rights may be restricted.")
add("q_pol_23","political_science","pol_ch2","The right to move freely across India is secured under which Article?",
    [{"id":"a","text":"Article 17"},{"id":"b","text":"Article 19"},{"id":"c","text":"Article 21"},{"id":"d","text":"Article 25"}],"b","medium",
    expl="Article 19 gives the freedom to move freely and reside anywhere in India.")

# pol_ch3: +8 (have 0)
add("q_pol_24","political_science","pol_ch3","Elections in India are conducted by the:",
    [{"id":"a","text":"President"},{"id":"b","text":"Election Commission of India"},{"id":"c","text":"Supreme Court"},{"id":"d","text":"Parliament only"}],"b","easy",
    expl="The independent Election Commission conducts free and fair elections.")
add("q_pol_25","political_science","pol_ch3","The minimum voting age in India is:",
    [{"id":"a","text":"16"},{"id":"b","text":"18"},{"id":"c","text":"21"},{"id":"d","text":"25"}],"b","easy",
    expl="The 61st Amendment (1988) reduced voting age from 21 to 18.")
add("q_pol_26","political_science","pol_ch3","India follows which system of elections?",
    [{"id":"a","text":"Proportional representation"},{"id":"b","text":"First Past the Post"},{"id":"c","text":"Mixed system"},{"id":"d","text":"Indirect only"}],"b","medium",
    expl="Lok Sabha and Assembly elections use the First Past the Post system.")
add("q_pol_27","political_science","pol_ch3","Model Code of Conduct applies to:",
    [{"id":"a","text":"Civil servants only"},{"id":"b","text":"Political parties and candidates during elections"},{"id":"c","text":"Judges"},{"id":"d","text":"News channels"}],"b","medium",
    expl="The Model Code sets norms for parties and candidates in election campaigns.")
add("q_pol_28","political_science","pol_ch3","One of the defects of the present election system identified by reformers is:",
    [{"id":"a","text":"Free media"},{"id":"b","text":"Money and muscle power"},{"id":"c","text":"Electronic voting"},{"id":"d","text":"Reserved seats"}],"b","easy",
    expl="Money, criminalisation and unfair polling practices are concerns flagged by reformers.")
add("q_pol_29","political_science","pol_ch3","Which of the following safeguards free and fair elections?",
    [{"id":"a","text":"Police firing"},{"id":"b","text":"Independent Election Commission"},{"id":"c","text":"Political violence"},{"id":"d","text":"Restricted voting"}],"b","easy",
    expl="An autonomous Election Commission is vital for fair polls.")
add("q_pol_30","political_science","pol_ch3","The 73rd and 74th Amendments strengthened which level of government?",
    [{"id":"a","text":"Centre"},{"id":"b","text":"States"},{"id":"c","text":"Panchayats and Municipalities"},{"id":"d","text":"Judiciary"}],"c","medium",
    expl="These amendments gave constitutional status to local self-government.")
add("q_pol_31","political_science","pol_ch3","A voter can, under the present system, cast vote for:",
    [{"id":"a","text":"All candidates of the constituency"},{"id":"b","text":"One candidate of the constituency"},{"id":"c","text":"Only the winning candidate"},{"id":"d","text":"A party not the candidate"}],"b","easy",
    expl="Each voter chooses one candidate from the candidates contesting that constituency.")

# pol_ch4: +8 (have 1)
add("q_pol_32","political_science","pol_ch4","The President of India is elected by:",
    [{"id":"a","text":"Direct vote of the people"},{"id":"b","text":"An electoral college"},{"id":"c","text":"The Prime Minister"},{"id":"d","text":"The Chief Justice"}],"b","easy",
    expl="The President is elected by an electoral college of MPs, MLAs and MLCs.")
add("q_pol_33","political_science","pol_ch4","The executive head of the Indian state government is the:",
    [{"id":"a","text":"President"},{"id":"b","text":"Governor"},{"id":"c","text":"Chief Minister"},{"id":"d","text":"Speaker"}],"b","medium",
    expl="The Governor is the constitutional head of a state.")
add("q_pol_34","political_science","pol_ch4","Article 74 says the President acts on the aid and advice of the:",
    [{"id":"a","text":"Parliament"},{"id":"b","text":"Supreme Court"},{"id":"c","text":"Council of Ministers headed by PM"},{"id":"d","text":"Election Commission"}],"c","medium",
    expl="The President exercises powers on the advice of the Council of Ministers.")
add("q_pol_35","political_science","pol_ch4","The President can declare National Emergency under Article:",
    [{"id":"a","text":"356"},{"id":"b","text":"352"},{"id":"c","text":"360"},{"id":"d","text":"368"}],"b","medium",
    expl="Article 352 covers National Emergency on war, external aggression or armed rebellion.")
add("q_pol_36","political_science","pol_ch4","Pardoning power of the President is given in Article:",
    [{"id":"a","text":"52"},{"id":"b","text":"72"},{"id":"c","text":"75"},{"id":"d","text":"123"}],"b","hard",
    expl="Article 72 grants the President the power to pardon and commute sentences.")
add("q_pol_37","political_science","pol_ch4","The President's Rule in a state is imposed under Article:",
    [{"id":"a","text":"352"},{"id":"b","text":"356"},{"id":"c","text":"360"},{"id":"d","text":"365"}],"b","medium",
    expl="Article 356 allows President's Rule when the state government fails constitutionally.")
add("q_pol_38","political_science","pol_ch4","The Chief Minister is appointed by the:",
    [{"id":"a","text":"President"},{"id":"b","text":"Governor"},{"id":"c","text":"Chief Justice"},{"id":"d","text":"Speaker"}],"b","easy",
    expl="The Governor appoints the Chief Minister of a state.")
add("q_pol_39","political_science","pol_ch4","The Vice-President of India is the ex-officio Chairman of the:",
    [{"id":"a","text":"Lok Sabha"},{"id":"b","text":"Rajya Sabha"},{"id":"c","text":"Supreme Court"},{"id":"d","text":"Planning Commission"}],"b","medium",
    expl="The Vice-President chairs the Rajya Sabha.")

# pol_ch5: +7 (have 1)
add("q_pol_40","political_science","pol_ch5","The Lower House of the Parliament of India is the:",
    [{"id":"a","text":"Rajya Sabha"},{"id":"b","text":"Lok Sabha"},{"id":"c","text":"Vidhan Sabha"},{"id":"d","text":"Vidhan Parishad"}],"b","easy",
    expl="Lok Sabha is the popularly elected Lower House of Parliament.")
add("q_pol_41","political_science","pol_ch5","The maximum strength of the Lok Sabha is:",
    [{"id":"a","text":"500"},{"id":"b","text":"550"},{"id":"c","text":"552"},{"id":"d","text":"600"}],"c","medium",
    expl="The Constitution sets the maximum strength of Lok Sabha at 552.")
add("q_pol_42","political_science","pol_ch5","The presiding officer of the Lok Sabha is the:",
    [{"id":"a","text":"President"},{"id":"b","text":"Speaker"},{"id":"c","text":"Vice-President"},{"id":"d","text":"Deputy Speaker alone"}],"b","easy",
    expl="The Speaker presides over Lok Sabha proceedings.")
add("q_pol_43","political_science","pol_ch5","Money Bills can only be introduced in the:",
    [{"id":"a","text":"Rajya Sabha"},{"id":"b","text":"Lok Sabha"},{"id":"c","text":"State Assembly"},{"id":"d","text":"President's office"}],"b","medium",
    expl="By Article 110, Money Bills originate only in the Lok Sabha.")
add("q_pol_44","political_science","pol_ch5","Rajya Sabha is also called the:",
    [{"id":"a","text":"Council of States"},{"id":"b","text":"House of People"},{"id":"c","text":"Legislative Council"},{"id":"d","text":"Federal Court"}],"a","medium",
    expl="Rajya Sabha is the Council of States, representing states and UTs.")
add("q_pol_45","political_science","pol_ch5","The ordinary term of the Lok Sabha is:",
    [{"id":"a","text":"4 years"},{"id":"b","text":"5 years"},{"id":"c","text":"6 years"},{"id":"d","text":"7 years"}],"b","easy",
    expl="Lok Sabha's normal term is five years (can be extended in Emergency).")
add("q_pol_46","political_science","pol_ch5","An ordinary bill can be deadlocked between the two Houses; the joint sitting is presided over by the:",
    [{"id":"a","text":"President"},{"id":"b","text":"Speaker of Lok Sabha"},{"id":"c","text":"Chairman of Rajya Sabha"},{"id":"d","text":"Vice-President"}],"b","hard",
    expl="Joint sittings are presided over by the Speaker of the Lok Sabha.")

# pol_ch6: +8 (have 1)
add("q_pol_47","political_science","pol_ch6","In a federal system the powers are divided between:",
    [{"id":"a","text":"President and Prime Minister"},{"id":"b","text":"Central and state governments"},{"id":"c","text":"Speaker and Deputy Speaker"},{"id":"d","text":"Judiciary and bureaucracy"}],"b","easy",
    expl="Federalism divides power between the central and state governments.")
add("q_pol_48","political_science","pol_ch6","The subject 'defence' is placed in the:",
    [{"id":"a","text":"State list"},{"id":"b","text":"Union list"},{"id":"c","text":"Concurrent list"},{"id":"d","text":"Residuary list"}],"b","medium",
    expl="The Union List (List I) covers subjects of national importance like defence.")
add("q_pol_49","political_science","pol_ch6","Which subject appears in the Concurrent List?",
    [{"id":"a","text":"Police"},{"id":"b","text":"Education"},{"id":"c","text":"Foreign affairs"},{"id":"d","text":"Currency"}],"b","medium",
    expl="Education, criminal law and marriage figure in the Concurrent List.")
add("q_pol_50","political_science","pol_ch6","In case of conflict between a Union law and a State law on a Concurrent subject:",
    [{"id":"a","text":"State law prevails"},{"id":"b","text":"Union law prevails"},{"id":"c","text":"President decides"},{"id":"d","text":"Both are void"}],"b","medium",
    expl="A Union law on a Concurrent subject prevails over a state law (Article 254).")
add("q_pol_51","political_science","pol_ch6","Indian federalism is described as a system that is:",
    [{"id":"a","text":"Purely federal"},{"id":"b","text":"Quasi-federal with unitary bias"},{"id":"c","text":"Purely unitary"},{"id":"d","text":"Confederal"}],"b","medium",
    expl="India is a federation with a strong centralising (unitary) bias.")
add("q_pol_52","political_science","pol_ch6","Which level of government provides for village Panchayats?",
    [{"id":"a","text":"Union"},{"id":"b","text":"State"},{"id":"c","text":"Local self-government"},{"id":"d","text":"High Court"}],"c","easy",
    expl="The 73rd Amendment created a three-tier system of local self-government.")
add("q_pol_53","political_science","pol_ch6","The special status provisions (Article 371) apply to:",
    [{"id":"a","text":"All states equally"},{"id":"b","text":"Certain states e.g. north-eastern states"},{"id":"c","text":"Only UTs"},{"id":"d","text":"Only Kashmir"}],"b","hard",
    expl="Articles 371A-H give special provisions to several states, mainly north-eastern.")
add("q_pol_54","political_science","pol_ch6","Inter-state disputes are settled by which institution?",
    [{"id":"a","text":"Parliament"},{"id":"b","text":"Supreme Court"},{"id":"c","text":"Election Commission"},{"id":"d","text":"Zonal Councils"}],"b","medium",
    expl="The Supreme Court adjudicates inter-state and federal disputes.")

# ============ ECONOMICS ============
# eco_ch1: +8 (have 2)
add("q_eco_6","economics","eco_ch1","At the time of independence, the share of agriculture in India's GDP was about:",
    [{"id":"a","text":"30%"},{"id":"b","text":"50%"},{"id":"c","text":"70%"},{"id":"d","text":"90%"}],"b","hard",
    expl="Agriculture contributed about 50% of national income at independence.")
add("q_eco_7","economics","eco_ch1","The British rule transformed India into a net exporter of:",
    [{"id":"a","text":"Machinery"},{"id":"b","text":"Raw materials"},{"id":"c","text":"Finished consumer goods"},{"id":"d","text":"Food grains only"}],"b","medium",
    expl="India supplied raw materials to Britain and imported finished goods.")
add("q_eco_8","economics","eco_ch1","India's share in world income at the beginning of the 20th century was about:",
    [{"id":"a","text":"20%"},{"id":"b","text":"15%"},{"id":"c","text":"6%"},{"id":"d","text":"30%"}],"c","hard",
    expl="India's share in world income had declined to about 6% in the early 20th century.")
add("q_eco_9","economics","eco_ch1","Which sector dominated the Indian economy on the eve of independence?",
    [{"id":"a","text":"Industry"},{"id":"b","text":"Agriculture"},{"id":"c","text":"Services"},{"id":"d","text":"Mining"}],"b","easy",
    expl="Agriculture was the mainstay of the Indian economy at independence.")
add("q_eco_10","economics","eco_ch1","The decline of which industry showed deindustrialisation under the British?",
    [{"id":"a","text":"Railways"},{"id":"b","text":"Handloom textiles"},{"id":"c","text":"Chemical industry"},{"id":"d","text":"Steel plants"}],"b","medium",
    expl="Indian handicrafts, especially textiles, declined due to British competition.")
add("q_eco_11","economics","eco_ch1","The Railway system was introduced in India by the British in:",
    [{"id":"a","text":"1800s"},{"id":"b","text":"1853"},{"id":"c","text":"1905"},{"id":"d","text":"1921"}],"b","easy",
    expl="The first railway line ran from Bombay to Thane in 1853.")
add("q_eco_12","economics","eco_ch1","The zamindari system under British rule benefited mainly:",
    [{"id":"a","text":"Peasants"},{"id":"b","text":"Landlords and the British state"},{"id":"c","text":"Traders only"},{"id":"d","text":"Artisans"}],"b","medium",
    expl="Zamindars collected rent for the state; peasants and tenancy suffered.")
add("q_eco_13","economics","eco_ch1","Economic growth during the colonial period was:",
    [{"id":"a","text":"Rapid"},{"id":"b","text":"Negligible and stagnant"},{"id":"c","text":"Moderate"},{"id":"d","text":"Highly industrial"}],"b","medium",
    expl="Colonial India had negligible or near-zero growth in per capita income.")

# eco_ch2: +9 (have 1)
add("q_eco_14","economics","eco_ch2","In the era of economic planning (1950-90), India adopted which type of planning model?",
    [{"id":"a","text":"Pure capitalism"},{"id":"b","text":"Mixed economy"},{"id":"c","text":"Command economy only"},{"id":"d","text":"Open market only"}],"b","medium",
    expl="India mixed state-led planning with a private sector — a mixed economy.")
add("q_eco_15","economics","eco_ch2","The main objective of Indian planning was:",
    [{"id":"a","text":"Maximum exports"},{"id":"b","text":"Growth, self-reliance and equity"},{"id":"c","text":"Foreign control"},{"id":"d","text":"Defence spending"}],"b","easy",
    expl="Plans aimed at rapid growth, modernisation, self-reliance and equity.")
add("q_eco_16","economics","eco_ch2","The Green Revolution was mainly concerned with:",
    [{"id":"a","text":"Industry"},{"id":"b","text":"Food grain production"},{"id":"c","text":"Exports"},{"id":"d","text":"Infrastructure"}],"b","easy",
    expl="The Green Revolution boosted wheat and rice output through HYV seeds and inputs.")
add("q_eco_17","economics","eco_ch2","HYV stands for:",
    [{"id":"a","text":"High Yield Variety"},{"id":"b","text":"Hybrid Yield Value"},{"id":"c","text":"High Yield Value"},{"id":"d","text":"High Yolo Volume"}],"a","easy",
    expl="High Yielding Variety seeds underpinned the Green Revolution.")
add("q_eco_18","economics","eco_ch2","The basic industries promoted under planning included:",
    [{"id":"a","text":"Textiles only"},{"id":"b","text":"Iron, steel and heavy machinery"},{"id":"c","text":"Tourism"},{"id":"d","text":"Export processing"}],"b","medium",
    expl="Planners focused on heavy basic industries like steel and machine tools.")
add("q_eco_19","economics","eco_ch2","Public sector enterprises set up during planning were in areas requiring:",
    [{"id":"a","text":"Small scale trade"},{"id":"b","text":"Heavy investment and strategic importance"},{"id":"c","text":"Private luxury goods"},{"id":"d","text":"Consumer goods only"}],"b","medium",
    expl="The public sector took up industries of strategic importance with heavy investment.")
add("q_eco_20","economics","eco_ch2","The National Sample Survey (NSS) measures:",
    [{"id":"a","text":"Agricultural output"},{"id":"b","text":"Household consumption and employment"},{"id":"c","text":"Share prices"},{"id":"d","text":"Exports only"}],"b","medium",
    expl="NSS collects data on consumption expenditure and employment.")
add("q_eco_21","economics","eco_ch2","India's industrial policy in 1956 was based on which resolution idea?",
    [{"id":"a","text":"Laissez faire"},{"id":"b","text":"Expanded role of the state"},{"id":"c","text":"No industry"},{"id":"d","text":"Only exports"}],"b","medium",
    expl="The Industrial Policy Resolution 1956 expanded the public sector's role.")
add("q_eco_22","economics","eco_ch2","A key negative outcome of planning (1950-90) was:",
    [{"id":"a","text":"High growth"},{"id":"b","text":"Inflation and inefficiency"},{"id":"c","text":"Full employment"},{"id":"d","text":"Poverty elimination"}],"b","medium",
    expl="Efficiency losses, high costs and slow employment growth were drawbacks.")

# eco_ch3: +8 (have 1)
add("q_eco_23","economics","eco_ch3","Liberalisation refers to:",
    [{"id":"a","text":"Import restrictions"},{"id":"b","text":"Reducing government controls on the economy"},{"id":"c","text":"Nationalisation"},{"id":"d","text":"Wage controls"}],"b","easy",
    expl="Liberalisation removed licence, quotas and state controls on industry.")
add("q_eco_24","economics","eco_ch3","Privatisation means:",
    [{"id":"a","text":"State ownership"},{"id":"b","text":"Transfer of ownership of public enterprises to private hands"},{"id":"c","text":"More subsidies"},{"id":"d","text":"Price controls"}],"b","easy",
    expl="Privatisation transfers state assets/management to the private sector.")
add("q_eco_25","economics","eco_ch3","One reason for the 1991 economic crisis was:",
    [{"id":"a","text":"Too much foreign exchange"},{"id":"b","text":"Balance of payments deficit and low reserves"},{"id":"c","text":"Excess exports"},{"id":"d","text":"High savings"}],"b","medium",
    expl="India faced a severe BoP crisis with dangerously low forex reserves in 1991.")
add("q_eco_26","economics","eco_ch3","'LPG' in the 1991 reforms stands for:",
    [{"id":"a","text":"Liberalisation, Privatisation, Globalisation"},{"id":"b","text":"Loans, Prices, Goods"},{"id":"c","text":"Labour, Production, Growth"},{"id":"d","text":"Land, Population, GDP"}],"a","easy",
    expl="The 1991 New Economic Policy was Liberalisation, Privatisation and Globalisation.")
add("q_eco_27","economics","eco_ch3","FDI stands for:",
    [{"id":"a","text":"Foreign Development Investment"},{"id":"b","text":"Foreign Direct Investment"},{"id":"c","text":"Federal Deposit Insurance"},{"id":"d","text":"Fast Developing Industry"}],"b","easy",
    expl="FDI is direct investment by foreign entities in domestic enterprises.")
add("q_eco_28","economics","eco_ch3","The 'licence-permit raj' refers to:",
    [{"id":"a","text":"Free trade"},{"id":"b","text":"Excessive bureaucratic controls on industry"},{"id":"c","text":"Insurance regulation"},{"id":"d","text":"Bank licences"}],"b","medium",
    expl="Red tape and licensing from the centrally planned era was called the licence raj.")
add("q_eco_29","economics","eco_ch3","WTO stands for:",
    [{"id":"a","text":"World Trade Organisation"},{"id":"b","text":"World Tariff Office"},{"id":"c","text":"World Tourism Organisation"},{"id":"d","text":"World Tax Order"}],"a","easy",
    expl="WTO regulates global trade; India joined in 1995.")
add("q_eco_30","economics","eco_ch3","The 1991 reforms were initiated under which approach?",
    [{"id":"a","text":"Socialism"},{"id":"b","text":"Market-friendly structural adjustment"},{"id":"c","text":"Import substitution"},{"id":"d","text":"Autarky"}],"b","medium",
    expl="IMF-backed structural reforms opened the Indian economy to markets in 1991.")

# eco_ch4: +7 (have 1)
add("q_eco_31","economics","eco_ch4","Poverty is measured in India using:",
    [{"id":"a","text":"GDP only"},{"id":"b","text":"Calorie intake and consumption expenditure"},{"id":"c","text":"Population size"},{"id":"d","text":"Literacy only"}],"b","medium",
    expl="India's poverty line is based on minimum calorie/consumption norms.")
add("q_eco_32","economics","eco_ch4","The Planning Commission defined poverty in terms of:",
    [{"id":"a","text":"Percentage of billionaires"},{"id":"b","text":"A minimum consumption expenditure"},{"id":"c","text":"School dropout rate"},{"id":"d","text":"Mortality only"}],"b","medium",
    expl="A per-capita monthly expenditure line separates the poor from the non-poor.")
add("q_eco_33","economics","eco_ch4","Which programme provides free/subsidised food grains to the poor?",
    [{"id":"a","text":"MNREGA"},{"id":"b","text":"PDS (Public Distribution System)"},{"id":"c","text":"Golden Quadrilateral"},{"id":"d","text":"Digital India"}],"b","easy",
    expl="PDS supplies subsidised food grains through ration shops.")
add("q_eco_34","economics","eco_ch4","MNREGA guarantees how many days of wage employment in a year?",
    [{"id":"a","text":"60"},{"id":"b","text":"100"},{"id":"c","text":"150"},{"id":"d","text":"200"}],"b","easy",
    expl="MGNREGA guarantees 100 days of employment per rural household per year.")
add("q_eco_35","economics","eco_ch4","Poverty in India is highest in which terrain/regions?",
    [{"id":"a","text":"Delhi"},{"id":"b","text":"Agricultural labour households and remote areas"},{"id":"c","text":"IT parks"},{"id":"d","text":"Hilly tourist towns"}],"b","medium",
    expl="Landless agricultural labourers and remote rural households are most vulnerable.")
add("q_eco_36","economics","eco_ch4","Which of the following is a poverty alleviation scheme?",
    [{"id":"a","text":"Swachh Bharat"},{"id":"b","text":"Antyodaya Anna Yojana"},{"id":"c","text":"Digital lockers"},{"id":"d","text":"e-Governance"}],"b","medium",
    expl="Antyodaya Anna Yojana gives highly subsidised grains to the poorest families.")
add("q_eco_37","economics","eco_ch4","An important cause of rural poverty is:",
    [{"id":"a","text":"High literacy"},{"id":"b","text":"Low asset-holding and unemployment in agriculture"},{"id":"c","text":"Too many factories"},{"id":"d","text":"Abundant rainfall"}],"b","easy",
    expl="Lack of land, skills and employment pushes rural households into poverty.")

# eco_ch5: +7 (have 0)
add("q_eco_38","economics","eco_ch5","Human capital refers to:",
    [{"id":"a","text":"Machines"},{"id":"b","text":"Knowledge, skills and health of people"},{"id":"c","text":"Bank deposits"},{"id":"d","text":"Natural resources"}],"b","easy",
    expl="Human capital is the stock of skills and productive knowledge in people.")
add("q_eco_39","economics","eco_ch5","Which example is an investment in human capital?",
    [{"id":"a","text":"Building a dam"},{"id":"b","text":"Education and health expenditure"},{"id":"c","text":"Buying gold"},{"id":"d","text":"Importing cars"}],"b","easy",
    expl="Spending on education, training and health builds human capital.")
add("q_eco_40","economics","eco_ch5","Education is a key component of:",
    [{"id":"a","text":"Physical capital"},{"id":"b","text":"Human capital formation"},{"id":"c","text":"Foreign reserves"},{"id":"d","text":"Trade"}],"b","easy",
    expl="Education is the most important source of human capital formation.")
add("q_eco_41","economics","eco_ch5","Human capital raises:",
    [{"id":"a","text":"Population only"},{"id":"b","text":"Productivity and income"},{"id":"c","text":"Pollution"},{"id":"d","text":"Imports only"}],"b","medium",
    expl="Skilled and healthy people produce more, boosting income and output.")
add("q_eco_42","economics","eco_ch5","Which Indian programme promotes adult literacy?",
    [{"id":"a","text":"PL480"},{"id":"b","text":"Sarva Shiksha Abhiyan / adult literacy programmes"},{"id":"c","text":"Green Revolution"},{"id":"d","text":"Golden Quadrilateral"}],"b","medium",
    expl="Sarva Shiksha Abhiyan and adult literacy campaigns spread basic education.")
add("q_eco_43","economics","eco_ch5","The 'brain drain' refers to:",
    [{"id":"a","text":"Loss of electricity"},{"id":"b","text":"Migration of skilled people abroad"},{"id":"c","text":"Loss of crops"},{"id":"d","text":"Deficit in trade"}],"b","easy",
    expl="Emigration of educated, skilled workers is called brain drain.")
add("q_eco_44","economics","eco_ch5","Health expenditure is treated as investment because:",
    [{"id":"a","text":"It raises taxes"},{"id":"b","text":"A healthy worker is more productive"},{"id":"c","text":"It cuts exports"},{"id":"d","text":"It reduces wages"}],"b","medium",
    expl="Better health raises worker efficiency, output and economic growth.")

# eco_ch6: +8 (have 0)
add("q_eco_45","economics","eco_ch6","Rural development focuses on:",
    [{"id":"a","text":"Cities only"},{"id":"b","text":"Improving livelihoods and welfare of rural people"},{"id":"c","text":"Only tourism"},{"id":"d","text":"Industry only"}],"b","easy",
    expl="Rural development aims to improve living standards of the rural population.")
add("q_eco_46","economics","eco_ch6","Micro-credit means:",
    [{"id":"a","text":"Large corporate loans"},{"id":"b","text":"Small loans given to the poor, often through self-help groups"},{"id":"c","text":"International aid"},{"id":"d","text":"Tax waivers"}],"b","easy",
    expl="SHGs and micro-finance institutions give small credit to the rural poor.")
add("q_eco_47","economics","eco_ch6","A Self-Help Group (SHG) typically consists of:",
    [{"id":"a","text":"Government officials"},{"id":"b","text":"10-20 members from a village/neighbourhood"},{"id":"c","text":"Big companies"},{"id":"d","text":"Banks only"}],"b","medium",
    expl="SHGs are small voluntary groups, mainly women, who save and lend to members.")
add("q_eco_48","economics","eco_ch6","The primary sector of the rural economy is:",
    [{"id":"a","text":"Manufacturing"},{"id":"b","text":"Agriculture and allied activities"},{"id":"c","text":"Banking"},{"id":"d","text":"IT services"}],"b","easy",
    expl="Agriculture and allied activities dominate the rural economy.")
add("q_eco_49","economics","eco_ch6","Institutional credit to farmers mainly comes from:",
    [{"id":"a","text":"Village moneylenders only"},{"id":"b","text":"Banks and co-operatives"},{"id":"c","text":"Foreign firms"},{"id":"d","text":"Brokers"}],"b","medium",
    expl="Banks, RRBs and co-operatives form institutional sources of farm credit.")
add("q_eco_50","economics","eco_ch6","NABARD supports:",
    [{"id":"a","text":"Space research"},{"id":"b","text":"Agricultural and rural development"},{"id":"c","text":"Textile exports"},{"id":"d","text":"Film industry"}],"b","medium",
    expl="NABARD is the apex bank for agriculture and rural development finance.")
add("q_eco_51","economics","eco_ch6","Co-operative movement in Indian agriculture aims to:",
    [{"id":"a","text":"Maximise moneylenders' profit"},{"id":"b","text":"Provide credit, inputs and marketing cooperatively"},{"id":"c","text":"Only export"},{"id":"d","text":"Raise import taxes"}],"b","medium",
    expl="Co-operatives provide inputs, credit and marketing support to farmers.")
add("q_eco_52","economics","eco_ch6","On-farm diversification includes:",
    [{"id":"a","text":"IT parks"},{"id":"b","text":"Horticulture, livestock and aquaculture on farms"},{"id":"c","text":"Shopping malls"},{"id":"d","text":"Airports"}],"b","medium",
    expl="Diversification moves farms into horticulture, dairying, poultry and fisheries.")

# ============ GEOGRAPHY ============
# geo_ch1: +7 (have 1)
add("q_geo_6","geography","geo_ch1","The total land area of India is about:",
    [{"id":"a","text":"2.4 million sq km"},{"id":"b","text":"3.28 million sq km"},{"id":"c","text":"4.5 million sq km"},{"id":"d","text":"1.2 million sq km"}],"b","easy",
    expl="India covers about 3.28 million sq km, about 2.4% of the world's area.")
add("q_geo_7","geography","geo_ch1","The Tropic of Cancer passes through how many Indian states?",
    [{"id":"a","text":"4"},{"id":"b","text":"6"},{"id":"c","text":"8"},{"id":"d","text":"10"}],"c","medium",
    expl="The Tropic of Cancer passes through 8 states of India.")
add("q_geo_8","geography","geo_ch1","India's southernmost point (mainland) is:",
    [{"id":"a","text":"Kanyakumari"},{"id":"b","text":"Indira Point"},{"id":"c","text":"Rameswaram"},{"id":"d","text":"Kochi"}],"a","medium",
    expl="Kanyakumari is the southernmost point of the Indian mainland (8°4'N).")
add("q_geo_9","geography","geo_ch1","The geographical extent of India lies between which longitudes?",
    [{"id":"a","text":"60°E and 90°E"},{"id":"b","text":"68°7'E and 97°25'E"},{"id":"c","text":"30°E and 60°E"},{"id":"d","text":"70°E and 100°E"}],"b","medium",
    expl="India extends from 68°7'E to 97°25'E in longitude.")
add("q_geo_10","geography","geo_ch1","India shares its longest land border with which country?",
    [{"id":"a","text":"Pakistan"},{"id":"b","text":"China"},{"id":"c","text":"Nepal"},{"id":"d","text":"Bangladesh"}],"d","hard",
    expl="India has the longest border with Bangladesh.")
add("q_geo_11","geography","geo_ch1","The latitudinal extent of India (mainland) is:",
    [{"id":"a","text":"0° to 15°N"},{"id":"b","text":"8°4'N to 37°6'N"},{"id":"c","text":"37° to 50°N"},{"id":"d","text":"5° to 40°N"}],"b","medium",
    expl="India's mainland extends from 8°4'N to 37°6'N.")
add("q_geo_12","geography","geo_ch1","Which strait separates India from Sri Lanka?",
    [{"id":"a","text":"Strait of Malacca"},{"id":"b","text":"Palk Strait"},{"id":"c","text":"Bosphorus"},{"id":"d","text":"Gibraltar"}],"b","medium",
    expl="The Palk Strait and Gulf of Mannar separate India from Sri Lanka.")

# geo_ch2: +9 (have 1)
add("q_geo_13","geography","geo_ch2","The old fold mountain of India is the:",
    [{"id":"a","text":"Himalayas"},{"id":"b","text":"Aravallis"},{"id":"c","text":"Karakoram"},{"id":"d","text":"Vindhyas"}],"b","medium",
    expl="The Aravallis are ancient, denuded fold mountains, much older than the Himalayas.")
add("q_geo_14","geography","geo_ch2","The Himalayas were formed by the collision of which plates?",
    [{"id":"a","text":"Pacific and North American"},{"id":"b","text":"Indian and Eurasian plates"},{"id":"c","text":"African and European"},{"id":"d","text":"Australian and Antarctic"}],"b","medium",
    expl="The Indian plate collided with the Eurasian plate about 40-50 million years ago.")
add("q_geo_15","geography","geo_ch2","The northernmost range of the Himalayas is called:",
    [{"id":"a","text":"Shiwaliks"},{"id":"b","text":"Himadri (Greater Himalayas)"},{"id":"c","text":"Himachal"},{"id":"d","text":"Trans-Himalayas"}],"b","medium",
    expl="The Himadri or Greater Himalayas form the northernmost, highest range.")
add("q_geo_16","geography","geo_ch2","The Deccan Plateau is delimited on its north by:",
    [{"id":"a","text":"The Himalayas"},{"id":"b","text":"The Satpura range and Narmada river"},{"id":"c","text":"The Western coast"},{"id":"d","text":"The Jhelum"}],"b","hard",
    expl="The Satpura range and the Narmada form the northern edge of the Deccan.")
add("q_geo_17","geography","geo_ch2","The Peninsular plateau consists mainly of:",
    [{"id":"a","text":"Young fold rocks"},{"id":"b","text":"Old crystalline and hard igneous rocks"},{"id":"c","text":"Alluvial sand"},{"id":"d","text":"Volcanic ash only"}],"b","medium",
    expl="The plateau is built of ancient crystalline, hard rocks that resist erosion.")
add("q_geo_18","geography","geo_ch2","The Western Ghats are continuous except for one major gap called the:",
    [{"id":"a","text":"Palghat Gap"},{"id":"b","text":"Khyber Pass"},{"id":"c","text":"Thal Ghat only"},{"id":"d","text":"Siliguri Gap"}],"a","hard",
    expl="The Palghat Gap breaks the continuity of the Western Ghats.")
add("q_geo_19","geography","geo_ch2","The highest peak of the Himalayas (and the world) is:",
    [{"id":"a","text":"K2"},{"id":"b","text":"Mount Everest"},{"id":"c","text":"Nanga Parbat"},{"id":"d","text":"Kanchenjunga"}],"b","easy",
    expl="Mount Everest (8848 m) in Nepal is the world's highest peak.")
add("q_geo_20","geography","geo_ch2","The Kosi river is called the 'Sorrow of Bihar' because of:",
    [{"id":"a","text":"Excess salt"},{"id":"b","text":"Frequent floods and shifting course"},{"id":"c","text":"Water scarcity"},{"id":"d","text":"Dams"}],"b","medium",
    expl="The Kosi floods Bihar almost annually, earning the nickname.")
add("q_geo_21","geography","geo_ch2","The northern plains of India are formed by:",
    [{"id":"a","text":"Glaciers only"},{"id":"b","text":"Alluvium deposited by rivers"},{"id":"c","text":"Lava flows"},{"id":"d","text":"Wind-blown sand"}],"b","easy",
    expl="The Indo-Gangetic plains are composed of river-deposited alluvium.")

# geo_ch3: +8 (have 1)
add("q_geo_22","geography","geo_ch3","The Indus, Ganga and Brahmaputra belong to which drainage system?",
    [{"id":"a","text":"Peninsular rivers"},{"id":"b","text":"Himalayan drainage"},{"id":"c","text":"Inland drainage"},{"id":"d","text":"Coastal rivers"}],"b","easy",
    expl="The Himalayan rivers drain into the Bay of Bengal through the Ganga-Brahmaputra system.")
add("q_geo_23","geography","geo_ch3","The longest river of South India is the:",
    [{"id":"a","text":"Narmada"},{"id":"b","text":"Godavari"},{"id":"c","text":"Krishna"},{"id":"d","text":"Kaveri"}],"b","medium",
    expl="The Godavari (~1465 km) is the longest peninsular river.")
add("q_geo_24","geography","geo_ch3","Which peninsular river flows into the Arabian Sea?",
    [{"id":"a","text":"Godavari"},{"id":"b","text":"Mahanadi"},{"id":"c","text":"Narmada"},{"id":"d","text":"Krishna"}],"c","medium",
    expl="The Narmada and Tapi flow west into the Arabian Sea.")
add("q_geo_25","geography","geo_ch3","The delta formed by Kaveri is called:",
    [{"id":"a","text":"Sundarbans"},{"id":"b","text":"Kavery delta (Tamil Nadu)"},{"id":"c","text":"Hooghly delta"},{"id":"d","text":"Mahanadi delta"}],"b","easy",
    expl="The Kaveri makes a fertile delta in Tamil Nadu.")
add("q_geo_26","geography","geo_ch3","Which river is considered the 'Sorrow of Bengal'?",
    [{"id":"a","text":"Mahanadi"},{"id":"b","text":"Damodar"},{"id":"c","text":"Tapi"},{"id":"d","text":"Mahi"}],"b","medium",
    expl="The Damodar (now tamed by dams) was called the Sorrow of Bengal.")
add("q_geo_27","geography","geo_ch3","The Brahmaputra enters India through which state?",
    [{"id":"a","text":"Sikkim"},{"id":"b","text":"Arunachal Pradesh"},{"id":"c","text":"Assam"},{"id":"d","text":"West Bengal"}],"b","medium",
    expl="The Brahmaputra enters India through Arunachal Pradesh (as Siang/Dihang).")
add("q_geo_28","geography","geo_ch3","An example of a rift valley river of India is the:",
    [{"id":"a","text":"Ganga"},{"id":"b","text":"Narmada"},{"id":"c","text":"Godavari"},{"id":"d","text":"Beas"}],"b","medium",
    expl="The Narmada flows through a rift valley between the Vindhyas and Satpuras.")
add("q_geo_29","geography","geo_ch3","The Ganga river system is formed chiefly by the meeting of:",
    [{"id":"a","text":"Alaknanda and Bhagirathi"},{"id":"b","text":"Beas and Sutlej"},{"id":"c","text":"Godavari and Krishna"},{"id":"d","text":"Ravi and Chenab"}],"a","medium",
    expl="The Alaknanda and Bhagirathi join at Devprayag to form the Ganga.")

# geo_ch4: +9 (have 1)
add("q_geo_30","geography","geo_ch4","India's climate is mainly:",
    [{"id":"a","text":"Desert type"},{"id":"b","text":"Monsoon type"},{"id":"c","text":"Tundra"},{"id":"d","text":"Mediterranean"}],"b","easy",
    expl="The monsoons dominate India's seasonal climate regime.")
add("q_geo_31","geography","geo_ch4","The south-west monsoon enters India through which coast first?",
    [{"id":"a","text":"Coromandel"},{"id":"b","text":"Malabar (Kerala)"},{"id":"c","text":"Konkan"},{"id":"d","text":"Northern plains"}],"b","medium",
    expl="The SW monsoon first strikes the Kerala (Malabar) coast around 1 June.")
add("q_geo_32","geography","geo_ch4","The monsoon winds are a form of:",
    [{"id":"a","text":"Westerlies"},{"id":"b","text":"Seasonal reversal of winds"},{"id":"c","text":"Trade winds only"},{"id":"d","text":"Jet streams only"}],"b","easy",
    expl="Monsoons blow sea-to-land in summer and reverse in winter.")
add("q_geo_33","geography","geo_ch4","Which of the following brings the north-east monsoon rains to Tamil Nadu?",
    [{"id":"a","text":"South-west monsoon"},{"id":"b","text":"Retreating/north-east monsoon"},{"id":"c","text":"Western disturbances"},{"id":"d","text":"Cyclones in October only"}],"b","medium",
    expl="The retreating NE monsoon gives Tamil Nadu most of its winter rain.")
add("q_geo_34","geography","geo_ch4","El Nino is linked to:",
    [{"id":"a","text":"Cooling of the Pacific"},{"id":"b","text":"Warming of the eastern Pacific and weaker monsoons"},{"id":"c","text":"Antarctic winds"},{"id":"d","text":"Volcanic activity"}],"b","medium",
    expl="El Nino warms the east Pacific and is often associated with weak Indian monsoons.")
add("q_geo_35","geography","geo_ch4","Which type of climate region covers most of the Indian subcontinent?",
    [{"id":"a","text":"Equatorial"},{"id":"b","text":"Tropical monsoon"},{"id":"c","text":"Steppe"},{"id":"d","text":"Tundra"}],"b","easy",
    expl="Most of India has a tropical monsoon climate with a distinct wet-dry rhythm.")
add("q_geo_36","geography","geo_ch4","'Western Disturbances' bring rain to which parts of India in winter?",
    [{"id":"a","text":"South India"},{"id":"b","text":"Northern/western India"},{"id":"c","text":"Eastern coast"},{"id":"d","text":"Andamans"}],"b","medium",
    expl="Winter rainfall in north-west India comes from western disturbances.")
add("q_geo_37","geography","geo_ch4","The retreating monsoon season lasts from:",
    [{"id":"a","text":"June to September"},{"id":"b","text":"October to December"},{"id":"c","text":"January to March"},{"id":"d","text":"April to June"}],"b","medium",
    expl="The retreating (post-monsoon) season spans October to December.")
add("q_geo_38","geography","geo_ch4","Mawsynram, the wettest place in India, receives most rain from the:",
    [{"id":"a","text":"North-east monsoon"},{"id":"b","text":"South-west monsoon"},{"id":"c","text":"Cyclonic storms"},{"id":"d","text":"Local thunderstorms"}],"b","medium",
    expl="Mawsynram in Meghalaya receives huge SW monsoon rain.")
add("q_geo_39","geography","geo_ch4","A major cause of the onset of the southwest monsoon is:",
    [{"id":"a","text":"Cooling of the Indian ocean"},{"id":"b","text":"Intense heating of the Tibetan plateau in summer"},{"id":"c","text":"Winter snowfall"},{"id":"d","text":"Desert storms"}],"b","hard",
    expl="Summer heating over the plateau creates a low-pressure area that draws monsoon winds.")

# geo_ch5: +8 (have 1)
add("q_geo_40","geography","geo_ch5","Tropical evergreen forests require which conditions?",
    [{"id":"a","text":"Low rainfall"},{"id":"b","text":"High temperature and heavy rainfall"},{"id":"c","text":"Cold climate"},{"id":"d","text":"Saline soil only"}],"b","easy",
    expl="Evergreen forests grow where rainfall exceeds 200 cm with high temperatures.")
add("q_geo_41","geography","geo_ch5","The main trees of tropical evergreen forests include:",
    [{"id":"a","text":"Sal and Teak"},{"id":"b","text":"Ebony, mahogany and rosewood"},{"id":"c","text":"Deodar and pine"},{"id":"d","text":"Kikar and babool"}],"b","medium",
    expl="Ebony, mahogany and rosewood are typical of evergreen forests.")
add("q_geo_42","geography","geo_ch5","Mangrove forests in India are mainly found in:",
    [{"id":"a","text":"Western Ghats"},{"id":"b","text":"The deltas — Sundarbans and coastal deltas"},{"id":"c","text":"Thar desert"},{"id":"d","text":"Himalayan slopes"}],"b","easy",
    expl="Mangroves flourish in tidal deltas such as the Sundarbans.")
add("q_geo_43","geography","geo_ch5","The most fertile soil of India for agriculture is:",
    [{"id":"a","text":"Red soil"},{"id":"b","text":"Alluvial soil"},{"id":"c","text":"Laterite soil"},{"id":"d","text":"Desert soil"}],"b","easy",
    expl="Alluvial soil in the northern plains is the most fertile and widespread.")
add("q_geo_44","geography","geo_ch5","Black soil is ideal for which crop?",
    [{"id":"a","text":"Tea"},{"id":"b","text":"Cotton"},{"id":"c","text":"Rice"},{"id":"d","text":"Sugarcane"}],"b","medium",
    expl="Black (regur) soil — moisture retentive — suits cotton cultivation.")
add("q_geo_45","geography","geo_ch5","Laterite soils are mainly found in:",
    [{"id":"a","text":"Himalayan peaks"},{"id":"b","text":"High rainfall areas like hills of the south"},{"id":"c","text":"Thar desert"},{"id":"d","text":"Snow-covered regions"}],"b","medium",
    expl="Laterite develops in areas of heavy rain and high temperature, e.g. Kerala hills.")
add("q_geo_46","geography","geo_ch5","Which soil is formed by the weathering of volcanic (basalt) rocks?",
    [{"id":"a","text":"Alluvial"},{"id":"b","text":"Black soil"},{"id":"c","text":"Red soil"},{"id":"d","text":"Saline soil"}],"b","medium",
    expl="Black soil derives from ancient basalt lava in the Deccan.")
add("q_geo_47","geography","geo_ch5","The Sundarbans is famous for:",
    [{"id":"a","text":"Pine forests"},{"id":"b","text":"Mangrove forests and Royal Bengal tiger"},{"id":"c","text":"Desert vegetation"},{"id":"d","text":"Alpine meadows"}],"b","easy",
    expl="The Sundarbans is the largest mangrove delta home of the Royal Bengal tiger.")

# ============ TOURISM ============
# tour_ch1: +7 (have 1)
add("q_tour_5","tourism","tour_ch1","The World Tourism Organisation is abbreviated as:",
    [{"id":"a","text":"WTO"},{"id":"b","text":"UNWTO"},{"id":"c","text":"WTTC"},{"id":"d","text":"IATA"}],"b","medium",
    expl="The United Nations World Tourism Organization (UNWTO) is the global tourism body.")
add("q_tour_6","tourism","tour_ch1","Which of these best defines a 'tourist'?",
    [{"id":"a","text":"Anyone moving within a city"},{"id":"b","text":"A person travelling to a place away from home for leisure/other purpose for less than a year"},{"id":"c","text":"A person who moves permanently"},{"id":"d","text":"A daily commuter"}],"b","medium",
    expl="UNWTO defines a tourist as travelling away from the usual residence for under one year.")
add("q_tour_7","tourism","tour_ch1","Tourism contributes to the economy mainly through:",
    [{"id":"a","text":"Taxes only"},{"id":"b","text":"Employment, foreign exchange and allied industries"},{"id":"c","text":"Defence spending"},{"id":"d","text":"Monetary policy"}],"b","easy",
    expl="Tourism creates jobs, earns foreign exchange and boosts allied sectors.")
add("q_tour_8","tourism","tour_ch1","Which is a tourist attraction based on culture?",
    [{"id":"a","text":"A ski resort"},{"id":"b","text":"Historic forts and museums"},{"id":"c","text":"A beach"},{"id":"d","text":"A wildlife sanctuary"}],"b","easy",
    expl="Heritage monuments, festivals and museums are cultural attractions.")
add("q_tour_9","tourism","tour_ch1","India's 'Incredible India' campaign is a:",
    [{"id":"a","text":"Defence programme"},{"id":"b","text":"Marketing campaign to promote tourism"},{"id":"c","text":"Farming scheme"},{"id":"d","text":"Railway project"}],"b","easy",
    expl="'Incredible India' markets India's tourism potential globally.")
add("q_tour_10","tourism","tour_ch1","The travel and tourism industry in India is among the world's:",
    [{"id":"a","text":"Smallest"},{"id":"b","text":"Largest and fastest growing"},{"id":"c","text":"Declining"},{"id":"d","text":"Unregulated only"}],"b","medium",
    expl="India ranks among the largest tourism economies globally.")
add("q_tour_11","tourism","tour_ch1","Which sector links tourism with local businesses like hotels and transport?",
    [{"id":"a","text":"Manufacturing"},{"id":"b","text":"Hospitality and travel trade"},{"id":"c","text":"Agriculture"},{"id":"d","text":"Mining"}],"b","medium",
    expl="Hotels, travel agencies, transport and restaurants form the tourism supply chain.")

# tour_ch2: +6 (have 1)
add("q_tour_12","tourism","tour_ch2","Which Indian state leads in domestic tourist arrivals?",
    [{"id":"a","text":"Sikkim"},{"id":"b","text":"Tamil Nadu/Uttar Pradesh (top states)"},{"id":"c","text":"Manipur"},{"id":"d","text":"Meghalaya"}],"b","hard",
    expl="Tamil Nadu and Uttar Pradesh usually top domestic tourist arrivals in India.")
add("q_tour_13","tourism","tour_ch2","The Ministry responsible for tourism promotion in India is the Ministry of:",
    [{"id":"a","text":"Defence"},{"id":"b","text":"Tourism"},{"id":"c","text":"Agriculture"},{"id":"d","text":"Power"}],"b","easy",
    expl="The Ministry of Tourism formulates tourism policies and schemes.")
add("q_tour_14","tourism","tour_ch2","'Swadesh Darshan' scheme of India aims to:",
    [{"id":"a","text":"Develop theme-based tourist circuits"},{"id":"b","text":"Build metro rail"},{"id":"c","text":"Promote only inbound flights"},{"id":"d","text":"Fish farming"}],"a","medium",
    expl="Swadesh Darshan develops theme-based tourist circuits across India.")
add("q_tour_15","tourism","tour_ch2","Which of the following is a major accommodation type?",
    [{"id":"a","text":"Railway track"},{"id":"b","text":"Hotel/resort/homestay"},{"id":"c","text":"Power plant"},{"id":"d","text":"Factory floor"}],"b","easy",
    expl="Hotels, resorts, homestays and hostels provide tourist accommodation.")
add("q_tour_16","tourism","tour_ch2","Foreign tourist arrivals bring India primarily:",
    [{"id":"a","text":"Foreign exchange earnings"},{"id":"b","text":"Food exports"},{"id":"c","text":"Machinery"},{"id":"d","text":"Vehicle imports"}],"a","easy",
    expl="Inbound tourism earns valuable foreign exchange for India.")
add("q_tour_17","tourism","tour_ch2","Railway explains that advance booking of tourist facilities is handled by:",
    [{"id":"a","text":"Railways only"},{"id":"b","text":"ITDC, IRCTC and licensed travel agents"},{"id":"c","text":"Banks"},{"id":"d","text":"Ports"}],"b","medium",
    expl="ITDC, IRCTC and tour operators manage ticketing and bookings.")

# tour_ch3: +8 (have 1)
add("q_tour_18","tourism","tour_ch3","The Taj Mahal is located in which state?",
    [{"id":"a","text":"Delhi"},{"id":"b","text":"Uttar Pradesh"},{"id":"c","text":"Maharashtra"},{"id":"d","text":"Rajasthan"}],"b","easy",
    expl="The Taj Mahal stands at Agra in Uttar Pradesh.")
add("q_tour_19","tourism","tour_ch3","Hawa Mahal, a famous heritage product, is in:",
    [{"id":"a","text":"Jaipur"},{"id":"b","text":"Mumbai"},{"id":"c","text":"Kolkata"},{"id":"d","text":"Chennai"}],"a","easy",
    expl="Hawa Mahal, the Palace of Winds, is a Jaipur landmark.")
add("q_tour_20","tourism","tour_ch3","The famous rock-cut Kailasa temple is located at:",
    [{"id":"a","text":"Khajuraho"},{"id":"b","text":"Ellora"},{"id":"c","text":"Hampi"},{"id":"d","text":"Sarnath"}],"b","medium",
    expl="The Kailasa temple at Ellora is a magnificent rock-cut temple.")
add("q_tour_21","tourism","tour_ch3","Which is a wellness tourism product of India?",
    [{"id":"a","text":"IT parks"},{"id":"b","text":"Ayurveda and yoga retreats in Kerala"},{"id":"c","text":"Theme parks only"},{"id":"d","text":"Call centres"}],"b","medium",
    expl="Kerala's ayurveda and yoga retreats attract wellness tourists.")
add("q_tour_22","tourism","tour_ch3","The Sundarbans tourist attraction is primarily:",
    [{"id":"a","text":"Ski slopes"},{"id":"b","text":"Mangrove forest and tiger ecosystem"},{"id":"c","text":"Desert dunes"},{"id":"d","text":"Coral reefs"}],"b","easy",
    expl="The Sundarbans mangrove ecosystem is a sought-after eco-tourist site.")
add("q_tour_23","tourism","tour_ch3","The beaches of Goa and Kovalam are classified as:",
    [{"id":"a","text":"Heritage products"},{"id":"b","text":"Coastal/sea tourism products"},{"id":"c","text":"Rural products"},{"id":"d","text":"Adventure training only"}],"b","medium",
    expl="Beach tourism in Goa, Kerala and the Andamans is a major coastal product.")
add("q_tour_24","tourism","tour_ch3","A cruise and island product of India is found in:",
    [{"id":"a","text":"Ladakh"},{"id":"b","text":"Lakshadweep and Andaman Isles"},{"id":"c","text":"Delhi"},{"id":"d","text":"Punjab plains"}],"b","medium",
    expl="Lakshadweep and Andaman-Nicobar offer island and cruise tourism.")
add("q_tour_25","tourism","tour_ch3","MICE tourism stands for:",
    [{"id":"a","text":"Meetings, Incentives, Conferences, Exhibitions"},{"id":"b","text":"Mountains, Islands, Coasts and Estuaries"},{"id":"c","text":"Museums, Ideas, Crafts and Events"},{"id":"d","text":"Markets and International Cultural Exchange"}],"a","medium",
    expl="MICE covers business tourism — meetings, incentives, conferences and exhibitions.")

# tour_ch4: +6 (have 1)
add("q_tour_26","tourism","tour_ch4","The marketing mix of tourism is popularly known as:",
    [{"id":"a","text":"4Ps (Product, Price, Place, Promotion)"},{"id":"b","text":"5S"},{"id":"c","text":"3Rs"},{"id":"d","text":"2Ts"}],"a","medium",
    expl="Tourism marketing uses product, price, place and promotion — the 4Ps.")
add("q_tour_27","tourism","tour_ch4","Eco-tourism stresses:",
    [{"id":"a","text":"Mass tourism"},{"id":"b","text":"Conservation and community benefit"},{"id":"c","text":"Commercial farming"},{"id":"d","text":"Building hotels everywhere"}],"b","easy",
    expl="Eco-tourism emphasises environmental conservation and local welfare.")
add("q_tour_28","tourism","tour_ch4","'Responsible Tourism' means:",
    [{"id":"a","text":"Tourism anywhere"},{"id":"b","text":"Minimising negative impacts and benefiting locals"},{"id":"c","text":"Avoiding tourism"},{"id":"d","text":"Only luxury travel"}],"b","medium",
    expl="Responsible tourism balances growth with sustainability and local benefits.")
add("q_tour_29","tourism","tour_ch4","Sustainable tourism aims to:",
    [{"id":"a","text":"Deplete resources"},{"id":"b","text":"Meet present needs without harming future generations"},{"id":"c","text":"Only maximise profit"},{"id":"d","text":"Increase pollution"}],"b","medium",
    expl="Sustainability balances economic, social and environmental goals.")
add("q_tour_30","tourism","tour_ch4","Word-of-mouth and social media in tourism are forms of:",
    [{"id":"a","text":"Promotion"},{"id":"b","text":"Product"},{"id":"c","text":"Pricing"},{"id":"d","text":"Transport"}],"a","easy",
    expl="Digital marketing and reviews promote destinations and services.")
add("q_tour_31","tourism","tour_ch4","A key benefit of eco-tourism is:",
    [{"id":"a","text":"Environmental degradation"},{"id":"b","text":"Funding conservation through tourist revenue"},{"id":"c","text":"Cutting jobs"},{"id":"d","text":"Harming wildlife"}],"b","medium",
    expl="Eco-tourism revenue can fund conservation of parks and species.")

# ============ ITI ============
# iti_ch1: +9 (have 1)
add("q_iti_5","iti","iti_ch1","The unit of electric current is:",
    [{"id":"a","text":"Volt"},{"id":"b","text":"Ampere"},{"id":"c","text":"Ohm"},{"id":"d","text":"Watt"}],"b","easy",
    expl="Electric current is measured in amperes (A).")
add("q_iti_6","iti","iti_ch1","The unit of electrical resistance is:",
    [{"id":"a","text":"Volt"},{"id":"b","text":"Ampere"},{"id":"c","text":"Ohm"},{"id":"d","text":"Coulomb"}],"c","easy",
    expl="Resistance is measured in ohms (Ω).")
add("q_iti_7","iti","iti_ch1","Electrical power is measured in:",
    [{"id":"a","text":"Volts"},{"id":"b","text":"Watts"},{"id":"c","text":"Ohms"},{"id":"d","text":"Henries"}],"b","easy",
    expl="Power in watts equals voltage times current (P = V × I).")
add("q_iti_8","iti","iti_ch1","In a series circuit, the total resistance is the:",
    [{"id":"a","text":"Product of resistances"},{"id":"b","text":"Sum of resistances"},{"id":"c","text":"Difference of resistances"},{"id":"d","text":"Same as voltage"}],"b","medium",
    expl="Series resistors add: R_total = R1 + R2 + ...")
add("q_iti_9","iti","iti_ch1","In a parallel circuit, the total current is:",
    [{"id":"a","text":"Shared equally only"},{"id":"b","text":"Sum of currents in each branch"},{"id":"c","text":"Always zero"},{"id":"d","text":"Equal to one resistor"}],"b","medium",
    expl="In parallel branches, currents add: I_total = I1 + I2 + ...")
add("q_iti_10","iti","iti_ch1","A fuse wire protects electric circuits from:",
    [{"id":"a","text":"Low voltage"},{"id":"b","text":"Overload and short circuits"},{"id":"c","text":"Humidity"},{"id":"d","text":"Slow speed"}],"b","easy",
    expl="The fuse melts under excess current, breaking the circuit.")
add("q_iti_11","iti","iti_ch1","The SI unit of electrical charge is the:",
    [{"id":"a","text":"Ampere"},{"id":"b","text":"Coulomb"},{"id":"c","text":"Volt"},{"id":"d","text":"Joule"}],"b","medium",
    expl="Charge is measured in coulombs (C).")
add("q_iti_12","iti","iti_ch1","A conductor carries:",
    [{"id":"a","text":"No current easily"},{"id":"b","text":"Current easily due to free electrons"},{"id":"c","text":"Current only when heated"},{"id":"d","text":"Voltage only"}],"b","easy",
    expl="Conductors like copper have free electrons that carry current.")
add("q_iti_13","iti","iti_ch1","Which material is a good conductor of electricity?",
    [{"id":"a","text":"Rubber"},{"id":"b","text":"Copper"},{"id":"c","text":"Plastic"},{"id":"d","text":"Glass"}],"b","easy",
    expl="Copper and aluminium are good electrical conductors.")

# iti_ch2: +7 (have 1)
add("q_iti_14","iti","iti_ch2","Which device is used to input text into a computer?",
    [{"id":"a","text":"Monitor"},{"id":"b","text":"Keyboard"},{"id":"c","text":"Printer"},{"id":"d","text":"Speaker"}],"b","easy",
    expl="The keyboard is the main text input device.")
add("q_iti_15","iti","iti_ch2","The 'brain' of a computer is the:",
    [{"id":"a","text":"Monitor"},{"id":"b","text":"CPU"},{"id":"c","text":"Mouse"},{"id":"d","text":"Modem"}],"b","easy",
    expl="The CPU processes instructions and controls the computer.")
add("q_iti_16","iti","iti_ch2","Which software is used to make spreadsheets?",
    [{"id":"a","text":"MS Word"},{"id":"b","text":"MS Excel"},{"id":"c","text":"Paint"},{"id":"d","text":"Notepad"}],"b","easy",
    expl="MS Excel handles spreadsheets and calculations.")
add("q_iti_17","iti","iti_ch2","A file is normally saved with which structure?",
    [{"id":"a","text":"A folder name"},{"id":"b","text":"Filename with extension"},{"id":"c","text":"A password"},{"id":"d","text":"A colour"}],"b","easy",
    expl="Files use 'name.extension' e.g. report.docx.")
add("q_iti_18","iti","iti_ch2","Which key combination copies selected text (Windows)?",
    [{"id":"a","text":"Ctrl + Z"},{"id":"b","text":"Ctrl + C"},{"id":"c","text":"Ctrl + P"},{"id":"d","text":"Ctrl + S"}],"b","easy",
    expl="Ctrl+C copies; Ctrl+V pastes.")
add("q_iti_19","iti","iti_ch2","Which output device prints documents on paper?",
    [{"id":"a","text":"Monitor"},{"id":"b","text":"Printer"},{"id":"c","text":"Scanner"},{"id":"d","text":"Webcam"}],"b","easy",
    expl="A printer produces hard copies on paper.")
add("q_iti_20","iti","iti_ch2","Which of the following is an operating system?",
    [{"id":"a","text":"MS Excel"},{"id":"b","text":"Windows"},{"id":"c","text":"Google Chrome"},{"id":"d","text":"VLC"}],"b","easy",
    expl="Windows, Linux and Android are operating systems.")

# iti_ch3: +7 (have 1)
add("q_iti_21","iti","iti_ch3","A diode allows current in:",
    [{"id":"a","text":"Both directions"},{"id":"b","text":"One direction only"},{"id":"c","text":"No direction"},{"id":"d","text":"Alternate directions only"}],"b","easy",
    expl="A p-n diode conducts only in the forward bias direction.")
add("q_iti_22","iti","iti_ch3","The basic component of an electronic circuit is the:",
    [{"id":"a","text":"Resistor/capacitor/transistor"},{"id":"b","text":"Nut-bolt"},{"id":"c","text":"Gear box"},{"id":"d","text":"Propeller"}],"a","medium",
    expl="Resistors, capacitors, diodes and transistors are basic electronic components.")
add("q_iti_23","iti","iti_ch3","Which component stores electric charge?",
    [{"id":"a","text":"Resistor"},{"id":"b","text":"Capacitor"},{"id":"c","text":"Inductor only"},{"id":"d","text":"Switch"}],"b","medium",
    expl="A capacitor stores charge in an electric field.")
add("q_iti_24","iti","iti_ch3","A transistor works as a:",
    [{"id":"a","text":"Protector only"},{"id":"b","text":"Switch and amplifier"},{"id":"c","text":"Power generator"},{"id":"d","text":"Display"}],"b","medium",
    expl="Transistors amplify signals and act as electronic switches.")
add("q_iti_25","iti","iti_ch3","The unit of capacitance is the:",
    [{"id":"a","text":"Ohm"},{"id":"b","text":"Farad"},{"id":"c","text":"Henry"},{"id":"d","text":"Hertz"}],"b","medium",
    expl="Capacitance is measured in farads (F).")
add("q_iti_26","iti","iti_ch3","AC stands for:",
    [{"id":"a","text":"Actual Current"},{"id":"b","text":"Alternating Current"},{"id":"c","text":"Applying Charge"},{"id":"d","text":"Across Capacity"}],"b","easy",
    expl="AC (alternating current) periodically reverses direction.")
add("q_iti_27","iti","iti_ch3","Soldering is used in electronics to:",
    [{"id":"a","text":"Cut plastic"},{"id":"b","text":"Join components on a PCB"},{"id":"c","text":"Paint boards"},{"id":"d","text":"Drill holes"}],"b","medium",
    expl="Soldering joins electronic components to printed circuit boards.")

# iti_ch4: +6 (have 1)
add("q_iti_28","iti","iti_ch4","Which tool is used for measuring the diameter of a wire?",
    [{"id":"a","text":"Hammer"},{"id":"b","text":"Vernier calliper/micrometre"},{"id":"c","text":"Screwdriver"},{"id":"d","text":"Pliers"}],"b","medium",
    expl="Vernier callipers and micrometres measure wire diameters precisely.")
add("q_iti_29","iti","iti_ch4","Before working on electrical circuits, you must:",
    [{"id":"a","text":"Increase voltage"},{"id":"b","text":"Switch off the power supply"},{"id":"c","text":"Wear metal rings"},{"id":"d","text":"Work with wet hands"}],"b","easy",
    expl="Always isolate/de-energise circuits before servicing them.")
add("q_iti_30","iti","iti_ch4","Insulated tools prevent which hazard?",
    [{"id":"a","text":"Dust"},{"id":"b","text":"Electric shock"},{"id":"c","text":"Noise"},{"id":"d","text":"Sunburn"}],"b","easy",
    expl="Insulated handles insulate the worker from live parts.")
add("q_iti_31","iti","iti_ch4","A 'first aid' box in a workshop must contain:",
    [{"id":"a","text":"Spare parts"},{"id":"b","text":"Bandages, antiseptic and dressings"},{"id":"c","text":"Lubricants"},{"id":"d","text":"Paints"}],"b","easy",
    expl="First aid kits carry antiseptics, bandages and dressings for injuries.")
add("q_iti_32","iti","iti_ch4","Which safety device protects a machine operator's eyes?",
    [{"id":"a","text":"Gloves"},{"id":"b","text":"Safety goggles"},{"id":"c","text":"Ear plugs only"},{"id":"d","text":"Apron"}],"b","easy",
    expl="Safety goggles shield eyes from sparks and debris.")
add("q_iti_33","iti","iti_ch4","Fire caused by electrical faults must be extinguished with:",
    [{"id":"a","text":"Water"},{"id":"b","text":"CO2 / dry chemical extinguisher"},{"id":"c","text":"Sand only (wrong)"},{"id":"d","text":"Oil"}],"b","medium",
    expl="CO2 or dry powder extinguishers are safe for electrical fires; never water.")


with open("extra_questions.json", "w", encoding="utf-8") as f:
    json.dump(Q, f, ensure_ascii=False, indent=1)
print("Generated", len(Q), "questions")