//
//  SectionedTableView.swift
//  CacheTrackerSectionedConsumerTests
//
//  Created by Siarhei Ladzeika on 11/14/17.
//  Copyright © 2017 Siarhei Ladzeika. All rights reserved.
//

import UIKit
import CacheTrackerConsumer

class SectionedTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    let adapter: CacheTrackerSectionedConsumer<SectionedTestItem>
    
    init(adapter: CacheTrackerSectionedConsumer<SectionedTestItem>) {
        self.adapter = adapter
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 480)), style: .plain)
        self.adapter.delegate = self
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return adapter.sectionsCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adapter.numberOfItems(at: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = adapter.object(at: indexPath)
        cell.textLabel?.text = item.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Default")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Default")
        }
        return cell!
    }
    
    
    
}
