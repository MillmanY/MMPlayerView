//
//  DemoSource.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2017/8/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

struct DataObj {
    var image: UIImage?
    var play_Url: URL?
    var title = ""
    var content = ""
}

class DemoSource: NSObject {
    static let shared = DemoSource()
    var demoData = [DataObj]()
    
    
    override init() {
        
        demoData += [
         DataObj(image: #imageLiteral(resourceName: "two"),
                 play_Url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!,
                 title: "Your Best American G",
                 content: "In this song, Mitski tells the story of a relationship that just isn't working out because of one very loaded word, \"American,\" and all the baggage it carries. The protagonist ends things, in part because she's tired of having to be someone she's not. The song builds to an epic chorus, in which Mitski slays her electric guitar and sings, \"you're an all-American boy / I guess I couldn't help trying to be your best American girl.\" In the end, she knows she doesn't need to apologize for who she is. \"Your mother wouldn't approve of how my mother raised me / But I do, I finally do,\" she sings. The song is brilliant for many reasons, but perhaps most of all for the way it forces us each to conjure up our \"all-American boy\" and then take issue with the fact that coming up with a picture of him was so easy.\r\n\r\n"),
         DataObj(image: #imageLiteral(resourceName: "three"),
                 play_Url: URL(string: "http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8")!,
                 title: "Ultralight Beam",
                 content: "“This is a God dream.” There are many ways to take this core phrase from the most haunting song this year has offered, uttered by the troubled seeker whose 2016 was both deeply fruitful and frighteningly off-kilter: as an expression of Kanye West’s desire to elevate himself beyond mere ego, or a way of sanctifying that ego; as a reminder of the need to honor the sacred or an assertion that secular music like his messy, vital, elusive, confrontational album The Life of Pablo can do that work while remaining true to the fallen spirit of the secular. As the track unfolds, West’s utterance starts to feel like a stage direction. Over a track that sounds like a couple of church musicians fiddling on the organ and a snare drum in an unlit sanctuary, West offers different voices the chance to articulate their God dreams. A child preacher sampled from Instagram shouts out the Devil. R&B mainstays Terius Nash and Kelly Price sing of trying to keep faith despite feeling abandoned, leading into a "),
         DataObj(image: #imageLiteral(resourceName: "four"),
                 play_Url: URL(string: "http://www.streambox.fr/playlists/test_001/stream.m3u8")!,
                 title: "You Want It Darker",
                 content: "Leonard Cohen died with just enough life to witness the release of his 14th and final record, You Want It Darker. The title track, one of the finest of his singular career, is hymnal and testament. It tells a tale of humans at their worst, of futility and belief. Cohen’s unmatched storytelling is why we revered him, but this one feels as if his intended audience was a higher power.\r\n\r\n"),
         DataObj(image: #imageLiteral(resourceName: "five"),
                 play_Url: URL(string: "https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560.m3u8")!,
                 title: "What It Means",
                 content: "Many activists rightly point out that it's white folks' duty to combat racism by engaging with other white folks. That's the sort of meaningful, necessary work that Drive-By Truckers, a Southern rock band whose fan base skews Caucasian, undertakes here. Patterson Hood grits his teeth with barely contained fury as he memorializes Michael Brown and Trayvon Martin over muddied open chords. But for all the righteous anger, this doesn't feel like sermonizing. The Truckers don't claim to have the answers; they just know that no one gets to dodge responsibility for the violence that killed those kids or the systems perpetuating it. \"What It Means\" is the kind of protest song we can wish were a relic of a bygone time. Yet as the names of black and brown Americans killed by police continue to become hashtags, it remains insistently, bitterly relevant.\r\n\r\n"),
         DataObj(image: #imageLiteral(resourceName: "six"),
                 play_Url: URL(string: "http://yt-dash-mse-test.commondatastorage.googleapis.com/media/car-20120827-85.mp4")!,
                 title: "Black Beatles",
                 content: "If the first 10 seconds of Rae Sremmurd’s “Black Beatles” don’t make you reach for your phone, congratulations: you’ve managed to seclude yourself from a phenomenon. The song has become the designated background music of social media’s latest takeover, the #mannequinchallenge. Started by a group of Black teenagers from Florida’s Edward H. White High School, the experiment has spread across the country and been attempted by everyone from the Golden State Warriors to Hillary Clinton to Sir Paul McCartney. Over Mike WiLL Made It’s undulating, laser beam-filled production, hip-hop’s most electrifying duo and the resurrected Gucci Mane reimagine what it means to be famous and powerful, just like Black social influencers have done time and again through every medium available to them.\r\n\r\n"),
         DataObj(image: #imageLiteral(resourceName: "seven"),
                 play_Url: URL(string: "http://www.html5videoplayer.net/videos/toystory.mp4")!,
                 title: "Blessings (Reprise)",
                 content: "“Blessings (Reprise)” is Chance the Rapper shedding the skin he used to wear as an average human being. In his words: “The people’s champ must be everything the people can’t be.” He uses Coloring Book’s outro as an opportunity to step into the glimmering suit of optimism he’s been threading together since 2013’s Acid Rap, which shone light on more dark days than bright ones. His positive outlook on life in the present has been hard-fought, but rewarding; it’s apparent in his clarity that he’s exactly where he wants to be. With minimal vocals underscoring his single verse, the Chi-Town golden child spits bar after bar of faithfulness, letting it be known that he’s not afraid to talk to and about God in public. Chancellor Bennett is clearly a found man, and he’s doing his best to lead his fans to the promised land of happiness and well-being.\r\n\r\n"),
         DataObj(image: #imageLiteral(resourceName: "eight"),
                 play_Url: URL(string: "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4")!,
                 title: "Cranes In The Sky",
                 content: "Solange Knowles has always had a voice. It rings out through her fashion choices, her myriad hair styles (don’t touch it), her activism, and her intentionally molasses-slow pace of self-realization; her 2016 album A Seat at the Table was four years in the making, and features wisdom imparted by her parents and legendary New Orleans rap pioneer Master P. The record’s lead single “Cranes in the Sky” is a journal entry torn delicately from Solange’s own notebook, dedicated to any person who’s been faced with a deep sense of unfulfillment. Any person who’s taken a long, hard look at the world and wondered, “How did we get here?” Any person who’s felt inexplicably alone while surrounded by millions of people. It’s a rejuvenating elixir for the broken, but undefeated.\r\n\r\n"),
         DataObj(image: #imageLiteral(resourceName: "nine"),
                 play_Url: URL(string: "http://content.jwplatform.com/manifests/vM7nH0Kl.m3u8")!,
                 title: "Old Friends",
                 content: "Pop anthems address universal feelings — pride, grief, righteous anger, the determination to survive — in the language of the moment. In 1963, Bob Dylan captured a rising tide of countercultural questioning in “Blowin’ in the Wind.” Disaffected Gen Xers in the 1990s heard their doubts echoed in Kurt Cobain’s way of saying, “whatever, nevermind.” This year calls for something different: hot sauce hidden in a handbag and the determination to slay. Beyoncé’s musical act of self-affirmation — “catch my fly and my cocky fresh” — is also a manifesto set to a laser-gun trap beat. The song announced Lemonade, the musical year’s strongest call to think about the complexities of America’s diasporic roots, and remains its most potent track. Rooted by producer Mike WiLL Made It in the trap music of today’s South, it’s a testament to African-American resilience in the face of storms and hate crimes, and to feminist erotic bravado grounded in economic self-reliance and communal vigilance. Beginning"),
         DataObj(image: #imageLiteral(resourceName: "ten"),
                 play_Url: URL(string: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8")!,
                 title: "Drone Bomb Me",
                 content: "This Montclair, N.J. band masterfully tinges its emo-infused indie rock with traces of shambling country twang, placing plinking banjo and pedal steel alongside grungy guitar. But what makes a Pinegrove song like \"Old Friends\" powerful is Evan Stephens Hall's voice quivering with the slightest of drawls at the end of each line. It's easy to hear the frayed nerves and the emotional weight behind his words — and practically impossible not to shout right along with him. With a wry observational wit and poetic touch, Hall describes being both too tethered to his past and increasingly rootless as he grieves the loss of someone close.\r\n\r\n"),
         DataObj(image: #imageLiteral(resourceName: "one"),
                 play_Url: URL(string: "http://mirrors.standaloneinstaller.com/video-sample/jellyfish-25-mbps-hd-hevc.mp4")!,
                 title: "Formation",
                 content: "Pop anthems address universal feelings — pride, grief, righteous anger, the determination to survive — in the language of the moment. In 1963, Bob Dylan captured a rising tide of countercultural questioning in “Blowin’ in the Wind.” Disaffected Gen Xers in the 1990s heard their doubts echoed in Kurt Cobain’s way of saying, “whatever, nevermind.” This year calls for something different: hot sauce hidden in a handbag and the determination to slay. Beyoncé’s musical act of self-affirmation — “catch my fly and my cocky fresh” — is also a manifesto set to a laser-gun trap beat. The song announced Lemonade, the musical year’s strongest call to think about the complexities of America’s diasporic roots, and remains its most potent track. Rooted by producer Mike WiLL Made It in the trap music of today’s South, it’s a testament to African-American resilience in the face of storms and hate crimes, and to feminist erotic bravado grounded in economic self-reliance and communal vigilance. Beginning")
        ]
    }
}
