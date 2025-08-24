UNIVERSAL_OUTLINE = [
    {"section": "Title Page"},
    {"section": "Book Title"},
    {"section": "Author Name (Shane Russell)"},
    {"section": "SIS LLC Imprint"},
    {"section": "Copyright Page"},
    {"section": "Copyright Year, SIS LLC"},
    {"section": "ISBN Placeholder"},
    {"section": "All Rights Reserved Statement"},
    {"section": "Dedication Page"},
    {"section": "Personal Dedication"},
    {"section": "Acknowledgments"},
    {"section": "Thanks, Recognitions, and Attributions"},
    {"section": "Table of Contents"},
    {"section": "Preface"},
    {"section": "Why the Book Was Written"},
    {"section": "Author’s Intent and Message"},
    {"section": "Introduction"},
    {"section": "A: Core Theme, Hook, and Purpose"},
    {"section": "B: Expansion and Deeper Context"},
]

# Chapters 1-20 with A and B subsections
for chapter in range(1, 21):
    UNIVERSAL_OUTLINE.append({"section": f"Chapter {chapter}"})
    UNIVERSAL_OUTLINE.append({"section": "A: Core Teaching, Story, or Principle"})
    UNIVERSAL_OUTLINE.append({"section": "B: Expansion, Depth, Examples, or Applications"})

UNIVERSAL_OUTLINE += [
    {"section": "Bonus Chapter"},
    {"section": "A: Surprise Insight, Hidden Teaching, or Advanced Principle"},
    {"section": "B: Expansion, Application, or Practical Roadmap"},
    {"section": "Conclusion"},
    {"section": "A: Summarize Key Lessons, Bring Closure"},
    {"section": "B: Inspire Forward Movement / Action"},
    {"section": "Author Bio"},
    {"section": "About Shane Russell"},
    {"section": "SIS LLC Mission and Larger System Context"},
    {"section": "Resources & Next Steps"},
    {"section": "Related Books & Workbooks"},
    {"section": "QR Games / SIS Ecosystem Tie-Ins"},
    {"section": "Contact Links & Website"},
    {"section": "Glossary of Terms"},
    {"section": "Index"},
    {"section": "Recommended Reading"},
    {"section": "Appendices"},
    {"section": "Study/Discussion Questions"},
    {"section": "Workbook / Exercises"},
    {"section": "Notes / References"},
    {"section": "Case Studies or Stories"},
    {"section": "FAQs"},
    {"section": "Future Works Preview"},
    {"section": "Special Offers / Codes"},
]