//
//  ArticleProviderTests.swift
//  sereviaTests
//
//  Created by ekatizzz on 24.05.2026.
//

import XCTest
@testable import serevia

final class ArticleProviderTests: XCTestCase {
    
    // MARK: - testArticlesLoad()
    
    func testArticlesLoad() {
        let content = ArticleProvider.getContent(for: "Управление стрессом")
        
        XCTAssertFalse(content.isEmpty)
    }
    
    // MARK: - testArticlesNotEmpty()
    
    func testArticlesNotEmpty() {
        let articleTitles = [
            "Управление стрессом",
            "Сила благодарности",
            "Осознанное дыхание",
            "Сон и восстановление",
            "Медитация для начинающих"
        ]
        
        for title in articleTitles {
            let content = ArticleProvider.getContent(for: title)
            
            XCTAssertFalse(
                content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                "Article content for '\(title)' should not be empty"
            )
        }
    }
    
    // MARK: - testArticleContainsTitle()
    
    func testArticleContainsTitle() {
        let content = ArticleProvider.getContent(for: "Сила благодарности")
        
        XCTAssertTrue(
            content.contains("благодар"),
            "Article should contain gratitude-related text"
        )
    }
    
    // MARK: - testArticleContainsContent()
    
    func testArticleContainsContent() {
        let content = ArticleProvider.getContent(for: "Осознанное дыхание")
        
        XCTAssertTrue(content.count > 300)
    }
    
    // MARK: - testUnknownArticleReturnsPlaceholder()
    
    func testUnknownArticleReturnsPlaceholder() {
        let content = ArticleProvider.getContent(for: "Несуществующая статья")
        
        XCTAssertEqual(content, "Текст статьи скоро появится...")
    }
    
    // MARK: - testStressArticleContainsExpectedText()
    
    func testStressArticleContainsExpectedText() {
        let content = ArticleProvider.getContent(for: "Управление стрессом")
        
        XCTAssertTrue(content.contains("кортизол"))
        XCTAssertTrue(content.contains("стресс"))
    }
    
    // MARK: - testMeditationArticleContainsExpectedText()
    
    func testMeditationArticleContainsExpectedText() {
        let content = ArticleProvider.getContent(for: "Медитация для начинающих")
        
        XCTAssertTrue(content.contains("дыхани"))
        XCTAssertTrue(content.contains("внимани"))
    }
    
    // MARK: - testSleepArticleContainsExpectedText()
    
    func testSleepArticleContainsExpectedText() {
        let content = ArticleProvider.getContent(for: "Сон и восстановление")
            .lowercased()

        XCTAssertTrue(content.contains("сон"))
        XCTAssertTrue(content.contains("кофеин"))
    }
    
    // MARK: - testArticleIdsUnique()
    // В текущей реализации ID нет,
    // поэтому проверяем уникальность контента
    
    func testArticleContentsUnique() {
        let titles = [
            "Управление стрессом",
            "Сила благодарности",
            "Осознанное дыхание",
            "Сон и восстановление",
            "Медитация для начинающих",
            "Позитивная психология"
        ]
        
        var contents: Set<String> = []
        
        for title in titles {
            let content = ArticleProvider.getContent(for: title)
            contents.insert(content)
        }
        
        XCTAssertEqual(contents.count, titles.count)
    }
    
    // MARK: - testAllArticlesContainSource()
    
    func testAllArticlesContainSource() {
        let titles = [
            "Управление стрессом",
            "Сила благодарности",
            "Осознанное дыхание",
            "Сон и восстановление",
            "Медитация для начинающих",
            "Позитивная психология",
            "Совы и жаворонки",
            "Эмоциональный интеллект",
            "Сила маленьких привычек",
            "Тело и тревога",
            "Выгорание: как распознать"
        ]
        
        for title in titles {
            let content = ArticleProvider.getContent(for: title)
            
            XCTAssertTrue(
                content.contains("Источник:"),
                "Article '\(title)' should contain source"
            )
        }
    }
    
    // MARK: - testArticlesAreLongEnough()
    
    func testArticlesAreLongEnough() {
        let titles = [
            "Управление стрессом",
            "Сила благодарности",
            "Осознанное дыхание",
            "Сон и восстановление",
            "Медитация для начинающих"
        ]
        
        for title in titles {
            let content = ArticleProvider.getContent(for: title)
            
            XCTAssertGreaterThan(
                content.count,
                1000,
                "Article '\(title)' is too short"
            )
        }
    }
}
