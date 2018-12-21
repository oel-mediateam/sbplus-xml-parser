/**
 StorybookXml.swift
 SbXmlParser
 
 This file contains public classes and structs that will serve as DTO for Storybook Plus XML data.
 
 Created by Ethan Lin on 6/27/18.
 Copyright © 2018 University of Wisconsin System Office of Academic and Student Affairs. All rights reserved.
*/

import Foundation

/// A Storybook Plus XML
public class StorybookXml {
    
    /// Variables to represent every elements in the XML
    public var accent: String
    public var pageImgFormat: String
    public var splashImgFormat: String
    public var analytics: Bool
    public var mathJax: Bool
    public var version: String
    public var setup: Setup
    public var sections: Array<Section>
    
    /**
     Initializes a new Storybook XML instance with full specification.
     
     - Parameters:
        - accent: the color accent
        - imgFormat: the page image format or file extension
        - splashFormat: the splash screen image format or file extension
        - analytics: enable or disable Google Analytics
        - mathJax: enable or disable MathJax
        - setup: a struct that contains presentation setup data
        - sections: an array of section struct which hold an array of page structs
        - xmlVersion: the version of the XML
     
     - Returns: A new Storybook XML instance.
     */
    public init( accent: String, imgFormat: String, splashFormat: String, analytics: Bool, mathJax: Bool, setup: Setup, sections: Array<Section>, xmlVersion: String ) {
        
        self.accent = accent
        self.pageImgFormat = imgFormat
        self.splashImgFormat = splashFormat
        self.analytics = analytics
        self.mathJax = mathJax
        self.setup = setup
        self.sections = sections
        self.version = xmlVersion
        
    }
    
    /**
     An alternative way to initialize a new Storybook XML instance with a partial specification.
     
     - Parameters:
        - accent: the color accent
        - imgFormat: the page image format or file extension
        - splashFormat: the splash screen image format or file extension
        - analytics: enable or disable Google Analytics
        - mathJax: enable or disable MathJax
        - xmlVersion: the version of the XML
     
     - Returns: A new Storybook XML instance with empty setup and section.
     */
    convenience public init( accent: String, imgFormat: String, splashFormat: String, analytics: Bool, mathJax: Bool, xmlVersion: String ) {
        
        self.init( accent: accent, imgFormat: imgFormat, splashFormat: splashFormat, analytics: analytics, mathJax: mathJax, setup: Setup(), sections: [], xmlVersion: xmlVersion )
        
    }
    
    /**
     Output the Storybook XML instance as a string.
     
     - Returns: A string contains all data in the Storybook XML instance.
     */
    public func toString() -> String {
        
        return "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><storybook accent=\"#\(self.accent)\" pageImgFormat=\"\(self.pageImgFormat)\" splashImgFormat=\"\(self.splashImgFormat)\" analytics=\"\(self.analytics.description)\" mathjax=\"\(self.mathJax.description)\" xmlVersion=\"\(self.version)\"><setup program=\"\(self.setup.program)\" course=\"\(self.setup.course)\"><title>\(self.setup.title)</title><subtitle>\(self.setup.subtitle)</subtitle><length>\(self.setup.length)</length><author name=\"\(self.setup.authorName)\"><![CDATA[\(self.setup.authorProfile)]]></author><generalInfo><![CDATA[\(self.setup.generalInfo)]]></generalInfo></setup>\(self.getSectionString())</storybook>".replacingOccurrences(of: "&", with: "&amp;")
        
    }
    
    #if os( OSX )
    /**
     Output the Storybook XML instance as a XML Document.
     
     - Returns: An XML Document object.
     */
    public func toXMLDoc() throws -> XMLDocument {
        
        return try XMLDocument(xmlString: self.toString(), options: [.nodePreserveCDATA])
        
    }
    #endif
    
    /**
     Obtain data in the sections array as a string.
     
     - Returns: A string contains all page data of all sections in the Storybook XML instance.
     */
    public func getSectionString() -> String {
        
        var sectionString: String = ""
        var count = 0;
        
        /// loop through section
        for section in self.sections {
            
            count += 1
            sectionString += "<section title=\"\(section.title)\">"
            
            if let innerPages = section.pages {
                
                /// loop through pages within a section
                for page in innerPages {
                    
                    sectionString += "<page type=\"\(page.type)\" src=\"\(page.src)\" title=\"\(page.title)\" transition=\"\(page.transition)\" embed=\"\(page.embed)\">"
                    
                    /// loop through segments within a page
                    if ( page.widget.count > 0 ) {
                        
                        sectionString += "<widget>"
                        
                        for segment in page.widget {
                            
                            sectionString += "<segment name=\"\(segment.name)\"><![CDATA[\(segment.content)]]></segment>"
                            
                        }
                        
                        sectionString += "</widget>"
                        
                    }
                    
                    /// loop through frames within a page
                    
                    if ( page.frames.count > 0 ) {
                        
                        for frame in page.frames {
                            
                            sectionString += "<frame start=\"\(frame)\" />"
                            
                        }
                        
                    }
                    
                    // get quiz item if quiz type
                    if ( page.type == "quiz" ) {
                        
                        sectionString += page.quiz.generateXML()
                        
                    } else {
                        
                        sectionString += "<note>\(page.notes)</note>"
                        
                    }
                    
                    // get audio if it is html
                    if( page.type == "html" && !page.audio.isEmpty ) {
                        
                        sectionString += "<audio src=\"\(page.audio)\" />"
                        
                    }
                    
                    sectionString += "</page>"
                    
                }
                
            }
            
            sectionString += "</section>"
            
        }
        
        return sectionString
        
    }
    
    /**
     Add setup information to the Storybook XML instance.
     
     - Parameter setup: The setup struct to be set.
     */
    public func setSetup( setup: Setup ) {
        
        self.setup = setup
        
    }
    
    /**
     Add a section to the sections array of the Storybook XML instance
     
     - Parameter section: The section struct to be added.
     */
    public func addSection(section: Section) {
        
        self.sections.append( section )
        
    }
    
    /**
     Delete a section from the sections array of the Storybook XML instance.
     Any pages under the section will be moved to previous section
     
     - Parameter at: the page index to remove.
     */
    public func deleteSection(at: Int) {
        
        if !sections.isEmpty && at > 0 {
            
            if let pages = sections[at].pages {
                
                let previousSection = sections[sections.index(before: at)]
                
                for page in pages {
                    previousSection.addPage(page: page)
                }
                
            }
            
            self.sections.remove(at: at)
            
        }
        
    }
    
    /**
     Delete a page from the sections array of the Storybook XML instance.
     
     - Parameters:
     - item: the page index
     - at: the section index
     */
    public func deletePage(item: Int, at: Int) {
        
        if !sections.isEmpty {
            
            if var pages = self.sections[at].pages {
                
                if pages.indices.contains(item) {
                    
                    pages.remove(at: item)
                    
                }
                
            }
            
        }
        
    }
    
    /**
     A a section from the sections array of the Storybook XML instance.
     Any pages under the section will be moved to previous section
     
     - Parameters:
     - page: a page object to add
     - at: the section index
     */
    public func addPage(page: Page, at: Int) {
        
        if !sections.isEmpty {
            
            if sections.indices.contains(at) {
                
                if var pages = sections[at].pages {
                    
                    pages.append(page)
                    
                }
                
            }
            
        }
        
    }
    
    /**
     Return sections as pages along with other regular pages under the sections
     
     - Returns: An array of pages.
     */
    public func getSectionAsPages() -> Array<Page> {
        
        var pages: Array<Page> = [Page]()
        var sectionCount: Int = 0
        var pageCount: Int = 0
        
        for section in self.sections {
            
            let sectionAlias: Page = Page()
            
            sectionAlias.type = "section"
            sectionAlias.title = ""
            sectionAlias.num = sectionCount
            
            sectionCount += 1
            pages.append(sectionAlias)
            
            if let innerPages = section.pages {
                
                var itemIndex: Int = 0
                
                for innerPage in innerPages {
                    innerPage.num = pageCount
                    innerPage.index.section = sectionAlias.num
                    innerPage.index.item = itemIndex
                    pageCount += 1
                    itemIndex += 1
                    pages.append(innerPage)
                }
                
            }
            
        }
        
        return pages
        
    }
    
    /**
     Return total number of sections
     
     - Returns: Number of sections.
     */
    public func getNumSections() -> Int {
        
        return sections.count
        
    }
    
}

// A setup element in a Storybook Plus XML
public struct Setup {
    
    public var program: String = ""
    public var course: String = ""
    public var title: String = ""
    public var subtitle: String = ""
    public var length: String = ""
    public var authorName: String = ""
    public var authorProfile: String = ""
    public var generalInfo: String = ""
    public var releaseYear: String = ""
    public var overrideProfile: Bool = false
    
    public init() {}
    
}

/// A section element in a Storybook Plus XML
public class Section {
    
    public var title: String = ""
    public var pages: Array<Page>?
    
    public init() {}
    
    public func addPage(page: Page) {
        pages?.append(page)
    }
    
}

// a page element in a Storybook XML
public class Page {
    
    public var type: String = ""
    public var src: String = ""
    public var title: String = ""
    public var transition: String = ""
    public var embed: Bool = false
    public var notes: String = ""
    public var widget: Array<Segment> = []
    public var frames: Array<String> = []
    public var quiz: QuizItem = QuizItem( type: "" )
    public var audio: String = ""
    public var num: Int = 0
    public var index: PageIndex = PageIndex()
    
    public init() {}
    
    /**
     Add a segment to the segments array of a page instance.
     
     - Parameter segment: the segment struct to be added.
     */
    public func addSegment( segment: Segment ) {
        
        self.widget.append( segment )
        
    }
    
    /**
     Add a frame to the frames array of a page instance.
     
     - Parameter frame: the frame timecode to be added.
     */
    public func addFrame( frame: String ) {
        
        self.frames.append( frame )
        
    }
    
}

public struct PageIndex {
    
    public var section: Int = 0
    public var item: Int = 0
    
    public init() {}
    
}

// A segment of a widget in a page element of a Storybook Plus XML
public struct Segment {
    
    public var name: String = ""
    public var content: String = ""
    
    public init() {}
    
}

// structs to hold related quiz elements for Storybook Plus page

public class QuizItem {
    
    public var question: [String: String] = [:]
    public var type: String = ""
    public var feedback: Feedback = Feedback()
    public var choices: Array<[String: String]> = []
    public var random: Bool = false
    public var answer: String = ""
    
    public init( type: String ) {
        
        self.type = type
        
    }
    
    public func generateXML() -> String {
        return ""
    }
    
}

public class ShortAnswer: QuizItem {
    
    public init() {
        
        super.init(type: "shortAnswer")
        
    }
    
    override public func generateXML() -> String {
        
        return "<shortAnswer><question image=\"\(self.question["image"]!)\" audio=\"\(self.question["audio"]!)\"><![CDATA[\(self.question["text"]!)]]></question><feedback><![CDATA[\(self.feedback.simple)]]></feedback></shortAnswer>"
        
    }
    
}

public class FillInTheBlank: QuizItem {
    
    public init() {
        
        super.init( type: "fillInTheBlank" )
        
    }
    
    override public func generateXML() -> String {
        
        return "<fillInTheBlank><question image=\"\(self.question["image"]!)\" audio=\"\(self.question["audio"]!)\"><![CDATA[\(self.question["text"]!)]]></question><answer>\(self.answer)</answer><correctFeedback><![CDATA[\(self.feedback.correct)]]></correctFeedback><![CDATA[\(self.feedback.incorrect)]]><incorrectFeedback></incorrectFeedback></fillInTheBlank>"
        
    }
    
}

public class MultipleChoiceSingle: QuizItem {
    
    public init() {
        
        super.init( type: "multipleChoiceSingle" )
        
    }
    
    override public func generateXML() -> String {
        
        var xml = "<multipleChoiceSingle><question image=\"\(self.question["image"]!)\" audio=\"\(self.question["audio"]!)\"><![CDATA[\(self.question["text"]!)]]></question><choices random=\"\(self.random)\">"
        
        for answer in self.choices {
            
            xml += "<answer image=\"\(answer["image"] ?? "")\" audio=\"\(answer["audio"] ?? "")\" correct=\"\(answer["correct"] ?? "")\"><value>\(answer["value"] ?? "")</value><feedback><![CDATA[\(answer["feedback"] ?? "")]]></feedback></answer>"
            
        }
        
        xml += "</choices></multipleChoiceSingle>"
        
        return xml
        
    }
    
}

public class MultipleChoiceMultiple: QuizItem {
    
    public init() {
        
        super.init( type: "multipleChoiceMultiple" )
        
    }
    
    override public func generateXML() -> String {
        
        var xml = "<multipleChoiceSingle><question image=\"\(self.question["image"]!)\" audio=\"\(self.question["audio"]!)\"><![CDATA[\(self.question["text"]!)]]></question><choices random=\"\(self.random)\">"
        
        for answer in self.choices {
            
            xml += "<answer image=\"\(answer["image"] ?? "")\" audio=\"\(answer["audio"] ?? "")\" correct=\"\(answer["correct"] ?? "")\"><value>\(answer["value"] ?? "")</value></answer>"
            
        }
        
        xml += "</choices><correctFeedback><![CDATA[\(self.feedback.correct)]]></correctFeedback><incorrectFeedback><![CDATA[\(self.feedback.incorrect)]]>)</incorrectFeedback></multipleChoiceSingle>"
        
        return xml
        
    }
    
}

public struct Feedback {
    
    public var simple: String = ""
    public var correct: String = ""
    public var incorrect: String = ""
    
    public init() {}
    
}
