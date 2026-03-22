# Auto-Glossary Demo Video Guide

## Video Specs
- **Length:** 2-3 minutes
- **Format:** 1920x1080 (1080p) or 1280x720 (720p)
- **Software Options:**
  - **Mac:** QuickTime (built-in screen recording) or OBS Studio (free)
  - **Windows:** OBS Studio (free) or Camtasia
  - **Online:** Loom (free for short videos)
- **Audio:** Clear voiceover OR on-screen text captions

## Equipment Needed
- Computer with screen recording software
- Microphone (or use text captions instead)
- Your MRDBID site running locally or on staging server
- Script (below)
- Test article with good examples

## Pre-Recording Checklist

### 1. Prepare Your Browser
- [ ] Close unnecessary tabs
- [ ] Use Chrome/Firefox in clean profile (no personal bookmarks)
- [ ] Set zoom to 100%
- [ ] Hide browser bookmarks bar
- [ ] Clear any notifications

### 2. Prepare Content
- [ ] Create test article with 5-10 glossary terms
- [ ] Create test mushroom with description using glossary terms
- [ ] Have `/glossary` page ready to show
- [ ] Clear any test data from screen

### 3. Technical Setup
- [ ] Rails server running smoothly
- [ ] Test all glossary interactions work
- [ ] Clear browser cache
- [ ] Test on actual screen resolution you'll record

### 4. Script Prep
- [ ] Read script out loud 2-3 times
- [ ] Time yourself (should be 2-3 minutes)
- [ ] Have water nearby
- [ ] Practice smooth cursor movements

---

## VIDEO SCRIPT

### OPENING (0:00-0:20) - 20 seconds
**Visual:** Landing page of MRDBID or generic article with technical terms

**Script/Caption:**
> "Have you ever read scientific content and felt lost because of technical jargon?
>
> Words like 'basidiospore', 'hymenium', and 'cap' stop beginners in their tracks.
>
> What if these terms automatically explained themselves?"

---

### THE PROBLEM (0:20-0:40) - 20 seconds
**Visual:** Show article with technical terms, cursor hovering looking confused

**Script/Caption:**
> "Traditional solutions are clunky:
> - Footnotes require scrolling
> - Glossary pages require leaving the content
> - Users give up and leave
>
> There's a better way."

---

### THE SOLUTION (0:40-1:00) - 20 seconds
**Visual:** Show same article but with dotted underlines on terms

**Script/Caption:**
> "Introducing Auto-Glossary - it automatically finds technical terms in your content
> and marks them with subtle dotted underlines.
>
> Powered by Wikipedia's glossaries, completely open source."

---

### DEMO: HOVER (1:00-1:20) - 20 seconds
**Visual:** Slowly hover over "basidiospore" - tooltip appears

**Script/Caption:**
> "Hover over any term for an instant definition preview.
>
> [Show tooltip appearing]
>
> No clicking required - just hover and learn.
>
> [Hover over 2-3 more terms, showing different tooltips]"

---

### DEMO: CLICK (1:20-1:40) - 20 seconds
**Visual:** Click on a term - modal opens with full definition

**Script/Caption:**
> "Want more details? Click any term for the complete definition.
>
> [Modal opens]
>
> Full definition with proper Wikipedia attribution.
>
> [Close modal, click another term to show it works consistently]"

---

### DEMO: BROWSE (1:40-2:00) - 20 seconds
**Visual:** Navigate to /glossary page

**Script/Caption:**
> "Users can also browse all available terms in one place.
>
> [Scroll through glossary list]
>
> Over 400 mycology terms from Wikipedia, automatically updated."

---

### FEATURES (2:00-2:20) - 20 seconds
**Visual:** Show code editor with simple implementation

**Script/Caption:**
> "For developers, it's incredibly simple:
>
> [Show code: <%= raw mark_glossary_terms(@article.body) %>]
>
> One line of code. That's it.
>
> Works with any text content - articles, descriptions, comments."

---

### TECHNICAL HIGHLIGHTS (2:20-2:40) - 20 seconds
**Visual:** Show multiple examples quickly

**Script/Caption:**
> "Smart features included:
> - Handles plurals automatically
> - First-occurrence marking to reduce clutter
> - 24-hour caching for speed
> - Mobile responsive
> - Fully accessible (keyboard navigation, screen readers)"

---

### CALL TO ACTION (2:40-3:00) - 20 seconds
**Visual:** Show auto-glossary.com website

**Script/Caption:**
> "Auto-Glossary is open source and coming soon.
>
> Visit auto-glossary.com to get notified when we launch.
>
> Perfect for educational sites, technical docs, and scientific content.
>
> Make your content accessible to everyone.
>
> [Show: auto-glossary.com]"

---

## RECORDING TIPS

### For Voiceover:
1. **Speak slowly and clearly** - You'll speed it up if needed
2. **Record in quiet room** - Turn off fans, close windows
3. **Use pop filter** or speak slightly off-axis from mic
4. **Record whole script in one take**, then edit out mistakes
5. **Pause 2 seconds between sections** for easier editing

### For Text Captions:
1. **Use large, readable font** (32-40pt)
2. **High contrast** (white text on dark semi-transparent background)
3. **Keep on screen 3-5 seconds** per caption
4. **Position at bottom** of screen, not covering important content
5. **Use bold for key terms** like "Auto-Glossary"

### Cursor Movements:
1. **Move slowly** - Fast cursor looks jerky
2. **Pause briefly** before clicking (1 second)
3. **Smooth movements** - don't jitter
4. **Draw attention** by circling important elements

### Screen Recording Settings:
1. **Record at 60fps** if possible (smoother)
2. **Hide desktop clutter** - record just browser window
3. **Use fullscreen or maximize browser**
4. **Turn off notifications** (Mac: Do Not Disturb)

---

## EDITING CHECKLIST

After recording, edit to:
- [ ] Remove dead air/long pauses
- [ ] Add background music (soft, non-intrusive)
- [ ] Add text overlays for key points
- [ ] Add smooth transitions between sections
- [ ] Include intro title card (3 seconds)
- [ ] Include outro with website URL (5 seconds)
- [ ] Export at 1080p, 30fps minimum
- [ ] Keep file size under 100MB

### Recommended Background Music:
- YouTube Audio Library (free, royalty-free)
- Incompetech.com (Kevin MacLeod - free with credit)
- Bensound.com (free for personal use)
- Look for: "tech", "corporate", "upbeat" tags
- Keep volume at 20-30% (don't overpower voice)

---

## FREE EDITING SOFTWARE

### Mac:
- **iMovie** (free, built-in) - Easy for beginners
- **DaVinci Resolve** (free) - Professional features

### Windows:
- **DaVinci Resolve** (free) - Professional
- **Shotcut** (free, open source)
- **VSDC** (free version available)

### Online:
- **Kapwing** (free tier available)
- **Clipchamp** (free tier available)

---

## ALTERNATIVE: NO-VOICEOVER VERSION

If you're not comfortable with voiceover:

1. **Record silently** with just cursor movements
2. **Add text captions** for all narration
3. **Use background music** throughout
4. **Make captions very clear** and easy to read
5. **Keep on screen longer** (5-7 seconds each)

This actually works great for social media where videos auto-play muted!

---

## DISTRIBUTION PLAN

Once video is ready, upload to:

1. **YouTube**
   - Title: "Auto-Glossary - Make Technical Content Accessible (Open Source)"
   - Description with links to auto-glossary.com and GitHub
   - Tags: rails, ruby, open source, education, accessibility

2. **Your website**
   - Embed on auto-glossary.com
   - Embed on MRDBID project showcase

3. **Social Media**
   - Twitter (1-2 minute cut)
   - LinkedIn (full version)
   - Reddit (r/rails, r/programming, r/mycology)

4. **Demo sites**
   - GitHub README
   - Product Hunt submission
   - HackerNews (in comments)

---

## EXAMPLE OPENING HOOKS

Pick one that resonates:

**Option 1 (Problem-focused):**
> "67% of users bounce from technical content because of confusing jargon. Here's how we solved it."

**Option 2 (Direct):**
> "This tool automatically explains technical terms with Wikipedia definitions. And it takes one line of code."

**Option 3 (Story):**
> "A beginner tried to learn about mushrooms. They gave up after the third paragraph. This shouldn't happen."

**Option 4 (Technical):**
> "We built a Rails helper that automatically highlights 400+ mycology terms with Wikipedia definitions. Let me show you."

---

## PRACTICE RUN

Before recording the real thing:

1. Do a full practice run without recording
2. Record a 30-second test clip
3. Watch it - check audio, video quality, cursor speed
4. Adjust and record again
5. When happy with test, record full video

---

## THUMBNAILS

Create eye-catching thumbnail (1280x720):

**Elements:**
- Screenshot of glossary tooltip in action
- Large text: "Auto-Glossary" or "Wikipedia + Your Content"
- Your face (optional but increases clicks)
- Bright colors, high contrast
- No small text

**Tools:**
- Canva (free templates)
- Figma (free)
- Photoshop (if you have it)

---

## Questions to Ask Yourself

Before recording:
- Is my screen clean and professional?
- Can I complete each section smoothly?
- Is the lighting/audio good?
- Do I sound energetic/engaged?

After recording:
- Would this convince ME to use this tool?
- Is anything confusing?
- Does it feel too slow or too fast?
- Is the audio clear throughout?

---

## BONUS: SHORTER VERSIONS

Create multiple lengths for different platforms:

- **15 seconds:** Just the hover demo (Twitter/Instagram)
- **30 seconds:** Hover + click demo (Social media ads)
- **1 minute:** Problem + solution + demo (Quick pitches)
- **3 minutes:** Full demo with all features (YouTube, website)

You can create these from the same footage!

---

## FINAL CHECKLIST

Before publishing:
- [ ] Video is 2-3 minutes
- [ ] Audio is clear (no background noise)
- [ ] Cursor movements are smooth
- [ ] All features demonstrated
- [ ] Call to action is clear
- [ ] Website URL shown at end
- [ ] Exported at high quality
- [ ] Thumbnail created
- [ ] Description written with links
- [ ] Ready to upload

---

Good luck! Remember: Done is better than perfect. Your first video might not be amazing, and that's okay. You can always make an updated version later.
