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
            DataObj(image: #imageLiteral(resourceName: "seven"),
                    play_Url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!,
                    title: "SRT File demo",
                    content: """
1
00:00:15,000 --> 00:00:17,951
At the left we can see...

2
00:00:18,166 --> 00:00:20,083
At the right we can see the...

3
00:00:20,119 --> 00:00:21,962
...the head-snarlers

4
00:00:21,999 --> 00:00:24,368
Everything is safe.
Perfectly safe.

5
00:00:24,582 --> 00:00:27,035
Emo?

6
00:00:28,206 --> 00:00:29,996
Watch out!

7
00:00:47,037 --> 00:00:48,494
Are you hurt?

8
00:00:51,994 --> 00:00:53,949
I don't think so.
You?

9
00:00:55,160 --> 00:00:56,985
I'm Ok.

10
00:00:57,118 --> 00:01:01,111
Get up.
Emo, it's not safe here.

11
00:01:02,034 --> 00:01:03,573
Let's go.

12
00:01:03,610 --> 00:01:05,114
What's next?

13
00:01:05,200 --> 00:01:09,146
You'll see!

14
00:01:16,032 --> 00:01:18,022
Emo.
This way.

15
00:01:34,237 --> 00:01:35,481
Follow me!

16
00:02:11,106 --> 00:02:12,480
Hurry Emo!

17
00:02:48,059 --> 00:02:49,930
You're not paying attention!

18
00:02:50,142 --> 00:02:54,052
I just want to answer the...
...phone.

19
00:02:54,974 --> 00:02:57,972
Emo, look,
I mean listen.

20
00:02:59,140 --> 00:03:02,008
You have to learn to listen.

21
00:03:03,140 --> 00:03:04,965
This is not some game.

22
00:03:05,056 --> 00:03:09,345
You, I mean we,
we could easily die out here.

23
00:03:10,014 --> 00:03:13,959
Listen,
listen to the sounds of the machine.

24
00:03:18,054 --> 00:03:20,009
Listen to your breathing.

25
00:04:27,001 --> 00:04:28,956
Well, don't you ever get tired of this?

26
00:04:29,084 --> 00:04:30,909
Tired?!?

27
00:04:31,126 --> 00:04:34,491
Emo, the machine is like clockwork.

28
00:04:35,083 --> 00:04:37,074
One move out of place...

29
00:04:37,166 --> 00:04:39,121
...and you're ground to a pulp.

30
00:04:40,958 --> 00:04:42,004
But isn't it -

31
00:04:42,041 --> 00:04:46,034
Pulp, Emo!
Is that what you want, pulp?

32
00:04:47,040 --> 00:04:48,995
Emo, your goal in life...

33
00:04:50,081 --> 00:04:51,953
...pulp?

34
00:05:41,156 --> 00:05:43,028
Emo, close your eyes.

35
00:05:44,156 --> 00:05:46,027
Why?
- Now!

36
00:05:51,155 --> 00:05:52,102
Ok.

37
00:05:53,113 --> 00:05:54,688
Good.

38
00:05:59,070 --> 00:06:02,103
What do you see at your left side, Emo?

39
00:06:04,028 --> 00:06:05,899
Nothing.
- Really?

40
00:06:06,027 --> 00:06:07,105
No, nothing at all.

41
00:06:07,944 --> 00:06:11,984
And at your right,
what do you see at your right side, Emo?

42
00:06:13,151 --> 00:06:16,102
The same Proog, exactly the same...

43
00:06:16,942 --> 00:06:19,098
...nothing!
- Great.

44
00:06:40,105 --> 00:06:42,724
Listen Proog! Do you hear that!

45
00:06:43,105 --> 00:06:44,894
Can we go here?

46
00:06:44,979 --> 00:06:47,894
There?
It isn't safe, Emo.

47
00:06:49,145 --> 00:06:52,013
But...
- Trust me, it's not.

48
00:06:53,020 --> 00:06:54,145
Maybe I could...

49
00:06:54,181 --> 00:06:55,969
No.

50
00:06:57,102 --> 00:06:59,934
NO!

51
00:07:00,144 --> 00:07:03,058
Any further questions, Emo?

52
00:07:03,976 --> 00:07:05,090
No.

53
00:07:09,059 --> 00:07:10,089
Emo?

54
00:07:11,142 --> 00:07:13,058
Emo, why...

55
00:07:13,095 --> 00:07:14,022
Emo...

56
00:07:14,058 --> 00:07:18,003
...why can't you see
the beauty of this place?

57
00:07:18,141 --> 00:07:20,048
The way it works.

58
00:07:20,140 --> 00:07:23,895
How perfect it is.

59
00:07:23,932 --> 00:07:26,964
No, Proog, I don't see.

60
00:07:27,056 --> 00:07:29,970
I don't see because there's nothing there.

61
00:07:31,055 --> 00:07:34,965
And why should I trust my
life to something that isn't there?

62
00:07:35,055 --> 00:07:36,926
Well can you tell me that?

63
00:07:37,054 --> 00:07:38,926
Answer me!

64
00:07:42,970 --> 00:07:44,000
Proog...

65
00:07:45,053 --> 00:07:46,985
...you're a sick man!

66
00:07:47,022 --> 00:07:48,918
Stay away from me!

67
00:07:52,052 --> 00:07:54,884
No! Emo! It's a trap!

68
00:07:55,135 --> 00:07:56,931
Hah, it's a trap.

69
00:07:56,968 --> 00:08:01,043
At the left side you can see
the hanging gardens of Babylon!

70
00:08:01,967 --> 00:08:03,957
How's that for a trap?

71
00:08:05,050 --> 00:08:06,922
No, Emo.

72
00:08:09,008 --> 00:08:12,088
At the right side you can see...
...well guess what...

73
00:08:12,924 --> 00:08:14,665
...the colossus of Rhodes!

74
00:08:15,132 --> 00:08:16,053
No!

75
00:08:16,090 --> 00:08:21,919
The colossus of Rhodes
and it is here just for you Proog.

76
00:08:51,001 --> 00:08:52,923
It is there...

77
00:08:52,959 --> 00:08:56,040
I'm telling you,
Emo...

78
00:08:57,000 --> 00:08:59,867
...it is.
"""),
            DataObj(image: #imageLiteral(resourceName: "vertical.png"),
            play_Url: URL(string: "http://www.exit109.com/~dnn/clips/RW20seconds_1.mp4")!,
            title: "Vertical Video",
            content: "This is a Vertical Video"),
            
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
