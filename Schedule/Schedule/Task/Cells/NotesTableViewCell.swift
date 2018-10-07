//
//  NotesTableViewCell.swift
//  Schedule
//
//  Created by HsinYuLi on 2018/10/3.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {

    @IBOutlet weak var notesTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateView(notes: String?, enabled: Bool) {

        notesTextView.text = notes

        notesTextView.isEditable = enabled
    }

}

extension NotesTableViewCell: TaskDelegate {

    func getContent<T>() -> T? {

        return notesTextView?.text as? T
    }

}
